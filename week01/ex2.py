def primes(end):
    odds = range(3, n + 1, 2)
    sieve = set(sum([list(range(odd * odd, end + 1, odd + odd)) for odd in odds], []))
    return [2] + [odd for odd in odds if odd not in sieve]


def gcd(a, b):
    while a != 0:
        a, b = b % a, a
    return b


def find_mod_inverse(a, m):
    if gcd(a, m) != 1:
        return None
    u1, u2, u3 = 1, 0, a
    v1, v2, v3 = 0, 1, m

    while v3 != 1:
        t = u3 // v3
        v1, v2, v3, u1, u2, u3 = (u1 - t * v1), (u2 - t * v2), (u3 - t * v3), v1, v2, v3

    if v2 > a:
        return v2 % a
    if v2 < 0:
        return a + v2


p = int(input("Enter value of p: "))
q = int(input("Enter value of q: "))
n = p * q
print(n)

phi = (p - 1) * (q - 1)
e = list(filter(lambda x: ((p - 1) % x != 0 and (q - 1) % x != 0), primes(phi)))[0]
print(e)

d = find_mod_inverse(phi, e)
print(d)
