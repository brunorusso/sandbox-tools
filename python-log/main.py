import logging

# Configuração do logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[logging.StreamHandler()]
)

def soma(a, b):
    try:
        logging.info(f"Executando soma: {a} + {b}")
        resultado = a + b
        logging.info(f"Resultado da soma: {resultado}")
        return resultado
    except Exception as e:
        logging.error(f"Erro ao executar soma: {e}")
        return None

def subtracao(a, b):
    try:
        logging.info(f"Executando subtracao: {a} - {b}")
        resultado = a-b
        logging.info(f"Resultado da subtracao: {resultado}")
        return resultado
    except Exception as e:
        logging.error(f"Erro ao executar subtracao: {e}")
        return None

def multiplicacao(a, b):
    try:
        logging.info(f"Executando multiplicacao: {a} * {b}")
        resultado = a*b
        logging.info(f"Resultado da multiplicacao: {resultado}")
        return resultado
    except Exception as e:
        logging.error(f"Erro ao executar multiplicacao: {e}")
        return None

def divisao(a, b):
    try:
        logging.info(f"Executando divisao: {a} / {b}")
        resultado = a / b
        logging.info(f"Resultado da divisao: {resultado}")
        return resultado
    except Exception as e:
        logging.error(f"Erro ao executar divisao: {e}")
        return None

def main():
    while True:
        print("\nCalculadora - Operações Básicas")
        print("1. Soma")
        print("2. Subtração")
        print("3. Multiplicação")
        print("4. Divisão")
        print("5. Sair")
        
        escolha = input("Escolha uma operação (1/2/3/4/5): ")
        
        if escolha == '5':
            #logging.info("Encerrando o programa.")
            print("Encerrando o programa. Até logo!")
            break

        if escolha not in ['1', '2', '3', '4']:
            #logging.warning("Escolha inválida.")
            print("Erro: Escolha inválida. Tente novamente.")
            continue

        try:
            num1 = float(input("Digite o primeiro número: "))
            num2 = float(input("Digite o segundo número: "))
            logging.info(f"Números inseridos: {num1}, {num2}")
        except ValueError:
            logging.error("Erro: Entrada inválida. Números esperados.")
            print("Erro: Por favor, insira números válidos.")
            continue

        if escolha == '1':
            print(f"Resultado: {soma(num1, num2)}")
        elif escolha == '2':
            print(f"Resultado: {subtracao(num1, num2)}")
        elif escolha == '3':
            print(f"Resultado: {multiplicacao(num1, num2)}")
        elif escolha == '4':
            print(f"Resultado: {divisao(num1, num2)}")

if __name__ == "__main__":
    main()