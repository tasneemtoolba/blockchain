#!/usr/bin/env python
# example of proof of work algorithm

import hashlib
import time
from flask import Flask, request
from waitress import serve

app = Flask(__name__)
max_nonce = 2 ** 32  # 4 billion


@app.route('/home')
def index():
    nonce = 0
    hash_result = ''
    difficulty_bits = int(request.args.get('difficultyBits'))
    print(request.args)
    difficulty = 2 ** difficulty_bits

    print("")
    print("Difficulty: %ld (%d bits)" % (difficulty, difficulty_bits))

    print("Starting search...")

    start_time = time.time()

    new_block = 'test block with transactions' + hash_result

    (hash_result, nonce) = proof_of_work(new_block, difficulty_bits, nonce)

    end_time = time.time()

    elapsed_time = end_time - start_time

    print("Elapsed time: %.4f seconds" % elapsed_time)

    if elapsed_time > 0:
        hash_power = float(int(nonce) / elapsed_time)
        print("Hashing power: %ld hashes per second" % hash_power)
    return f'<h1>{(hash_result, nonce)}</h2>'


def proof_of_work(header, difficulty_bits, nonce):
    target = 2 ** (256 - difficulty_bits)
    for nonce1 in range(max_nonce):
        hashResult = hashlib.sha256(str(header).encode('utf-8') + str(nonce1).encode('utf-8')).hexdigest()

        if int(hashResult, 16) < target:
            print("Success with nonce %d" % nonce1)
            print("Hash is %s" % hashResult)
            return hashResult, nonce1

    print("Failed after %d (max_nonce) tries" % nonce)
    return nonce


if __name__ == '__main__':
    serve(app, host="0.0.0.0", port=8080)
