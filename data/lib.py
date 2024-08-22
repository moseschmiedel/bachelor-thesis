import math

def alpha(factor):
    return factor / -20

def dzero(a, summand):
    return 10 ** (summand / (20 * a))

def solve_rssi(factor, summand):
    a = alpha(factor)
    d0 = dzero(a, summand)
    return (a, d0)
