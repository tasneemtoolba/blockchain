import psycopg2
import psycopg2.extras

hostname = 'localhost'
database = 'demo'
username = 'postgres'
pwd = 'abdullahToolbaata'
port_id = 5433
conn = None


def return_credits(cursor):
    select_script = '''SELECT credit,id FROM bank'''
    cursor.execute(select_script)
    account_records = cur.fetchall()
    for account in account_records:
        print("Account = ", account[0], )
        print("credit = ", account[1], "\n")


def transaction_without_fees(cursor, From, To, Amount, ID):
    transaction_script = f'''BEGIN;
                            UPDATE bank
                            SET credit = credit - {Amount}
                            WHERE id = {From};

                            UPDATE bank
                            SET credit = credit + {Amount}
                            WHERE id = {To};
                            
                            COMMIT;'''
    cursor.execute(transaction_script)

    cursor.execute(f'''INSERT INTO ledger (id, senderID, receiverID, fee, amount, transactionDateTime) VALUES ({ID},{From},{To},{0},{Amount},current_timestamp )''')


def add_bank_name(cursor):
    add_field_script = '''ALTER TABLE bank
                                      ADD COLUMN bank_name varchar(40);
                                      UPDATE bank
                                      SET bank_name = 'SpearBank'
                                      WHERE id = 1;

                                      UPDATE bank
                                      SET bank_name = 'Tinkoff'
                                      WHERE id = 2;

                                      UPDATE bank
                                      SET bank_name = 'SpearBank'
                                      WHERE id = 3;'''
    cursor.execute(add_field_script)


def transaction_with_fees(cursor, From, To, Amount, ID):
    cursor.execute(f'''SELECT bank_name FROM bank WHERE id = {From}''')
    bank_name_from = cursor.fetchall()
    cursor.execute(f'''SELECT bank_name FROM bank WHERE id = {To}''')
    bank_name_to = cursor.fetchall()
    fee = 0
    if bank_name_from[0][0] != bank_name_to[0][0]:
        fee = 30

    transaction_script = f'''BEGIN;
                            UPDATE bank
                            SET credit = credit - {Amount + fee}
                            WHERE id = {From};


                            UPDATE bank
                            SET credit = credit + {Amount}
                            WHERE id = {To};
                            
                            UPDATE bank
                            SET credit = credit + {fee}
                            WHERE id = 4;

                            COMMIT;'''
    cursor.execute(transaction_script)

    cursor.execute(f'''INSERT INTO ledger (id, senderID, receiverID, fee, amount, transactionDateTime) VALUES ({ID},{From},{To},{fee},{Amount},current_timestamp)''')


def create_tables(cursor):
    create_bank_script = ''' CREATE TABLE IF NOT EXISTS bank (
                                        id      int PRIMARY KEY,
                                        name    varchar(40) NOT NULL,
                                        credit  int);'''
    cursor.execute(create_bank_script)

    create_ledger_script = ''' CREATE TABLE IF NOT EXISTS ledger (
                                        id      int PRIMARY KEY,
                                        senderID    varchar(40) NOT NULL,
                                        receiverID      varchar(40) NOT NULL,
                                        fee     int,
                                        amount  int,
                                        transactionDateTime timestamptz);'''
    cursor.execute(create_ledger_script)


try:
    with psycopg2.connect(
            host=hostname,
            dbname=database,
            user=username,
            password=pwd,
            port=port_id) as conn:

        with conn.cursor(cursor_factory=psycopg2.extras.DictCursor) as cur:
            cur.execute('DROP TABLE IF EXISTS bank')
            cur.execute('DROP TABLE IF EXISTS ledger')

            create_tables(cur)

            insert_script = 'INSERT INTO bank (id, name, credit) VALUES (%s, %s, %s)'
            insert_values = [(1, 'James', 1000), (2, 'Robin', 1000), (3, 'Xavier', 1000)]
            for record in insert_values:
                cur.execute(insert_script, record)

            transaction_values = [(1, 3, 500), (2, 1, 700), (2, 3, 100)]
            transaction_ID = 1
            for record in transaction_values:
                transaction_without_fees(cur, record[0], record[1], record[2], transaction_ID)
                transaction_ID = transaction_ID + 1
            return_credits(cur)

            add_bank_name(cur)

            cur.execute(insert_script, (4, 'Fees', 0, ))

            for record in transaction_values:
                transaction_with_fees(cur, record[0], record[1], record[2], transaction_ID)
                transaction_ID = transaction_ID + 1

            return_credits(cur)

except Exception as error:
    print(error)
finally:
    if conn is not None:
        conn.close()
