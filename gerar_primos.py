from math import isqrt


def eh_primo(n: int) -> bool:
    if n < 2:
        return False
    if n == 2:
        return True
    if n % 2 == 0:
        return False
    limite = isqrt(n)
    for i in range(3, limite + 1, 2):
        if n % i == 0:
            return False
    return True


def primeiros_primos(qtd: int) -> list[int]:
    primos = []
    num = 2
    while len(primos) < qtd:
        if eh_primo(num):
            primos.append(num)
        num += 1
    return primos


if __name__ == "__main__":
    primos = primeiros_primos(100)
    with open("100_primos.txt", "w", encoding="utf-8") as arquivo:
        arquivo.write("\n".join(map(str, primos)))
    print("Arquivo '100_primos.txt' criado com sucesso.")
