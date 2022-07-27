# Apresentando as telas principais

1 - Tela Inicial da aplicação, contendo o campo para informar a URL, e os botões que vão acionar o start e stop do download.

![image](https://user-images.githubusercontent.com/109768902/181140304-49e08eb0-73ad-4ed7-9071-d76418b029df.png)

2 - Tela com download em andamento.

![image](https://user-images.githubusercontent.com/109768902/181140853-d24e7968-589e-4cad-a089-ae1d7b1fe0f9.png)

3 - Tela de histórico de downloads.

![image](https://user-images.githubusercontent.com/109768902/181141393-16b113ab-27a3-4f87-a0fc-0d9542dc7948.png)


# Download Application HTTP
 Esta aplicação tem o intuíto de facilitar o download de arquivos via desktop. Ela serve como meio para fazer downloads variados em qualquer página "http://". E tambem armazena o histórico de downloads feitos desde o início
 
# Programação Orientada a Objeto </h1>
 Aplicação foi escrita utilizando o paradigma de Orientadção a Objetos.
 
# Aplicação Multi-Threading 
 Utilizei a classe TTask da Uses System.Threading, para rodar uma thread em paralelo com a main thread, evitando assim a concorrência com a mesma, fazendo que a aplicação não fique travada ao fazer o download, podendo ser manipulada sem qualquer forma de travamento.

# Padrões de Projetos
 Foi utilizando o padrão de Observer para notificar a View sobre o progresso do download.

# Banco de Dados
 O banco escolhido foi SQLite, que contém apenas a tabela que armazena o histórico de downloads realizados, contendo a informação da URL, Data Inicio e Data Fim do download.

# Exceções
 A aplicação conta com o tratamento de exceções, utilizando boas práticas para tal.
 
# Observações
 A aplicação não está aceitando links "https://" no momento apenas "http://". Isso deverá ser corrigido o mais brevemente possível.
 
 
 
