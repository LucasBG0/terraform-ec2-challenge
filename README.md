# Instruções para executar o desafio
 
Meu objetivo nesse desafio foi subir uma infra totalmente gerenciada pelo terraform, exigindo apenas definir as variáveis no arquivo terraform.tfvars.
 
## Tecnologias utilizadas:
 
* Terraform 1.1.7
* AWS provider 4.8.0
* Containers Docker:
  1. Nginx como proxy reverso para o container da aplicação
  2. React rodando um node.js server
 
---
 
## Descrição da arquitetura:
 
1. Envio de uma chave pública pré-criada para a AWS;
2. 1 módulo para EC2: responsável por provisionar a instância, métricas Cloudwatch e roles;
3. 1 módulo para security group: atrelado aos recursos desejados;
4. Bucket S3 para envio do pacote debian (`scripts/react-app.deb`). Esse pacote contém uma aplicação simples em React que foi dockerizada, um container que será buildado no user_data da instância EC2, ou seja quando a instância for inicializada;
 
---

## Como subir a infra:

1. Primeiro é necessário se certificar que a AWS CLI está instalada e com as credenciais de uma conta AWS já configurada. É recomendado criar um grupo com as políticas `AmazonEC2FullAccess, IAMFullAccess e AmazonS3FullAccess` e em seguida criar um usuário e adicionar o novo grupo ao respectivo usuário.

2. Com a AWS CLI configurada, o próximo passo é definir algumas váriaveis no arquivo `terraform.tfvars`. Copie a partir do arquivo de exemplo:

```
cp terraform.tfvars.example terraform.tfvars
```

O arquivo `terraform.tfvars` conterá o seguinte:

```
instance = {
  "type"            = "t2.micro"
  "name"            = "web-server"
  "user_data_path"  = "scripts/init.sh"
  "key_name"        = "my-terraform-key"
  "public_key_path" = "~/.ssh/terraform.pub"
}

ssh_allow_cidr_blocks = ["179.214.12.153/32"]
```

* ssh_allow_cidr_blocks: Insira o seu IP público aqui, para que consiga acessar a instância via SSH.
* instance.public_key_path: **É obrigatório que a váriavel `instance.public_key_path` seja preenchida! Trata-se do caminho da chave ssh pública, que você precisa criar ou usar um par de chaves existente**
* instance.type: Tipo da instância
* instance.name: Nome da instância exibido na AWS.
* instance.user_data_path: Caminho do arquivo responsável por instalar e configurar todos os servicos quando a instância foi inicializada
* instance.key_name: Nome do par de chaves que será exibido lá na AWS
---
3. Após definir as varíaveis, rode os seguintes comandos:

* `terraform init` - Para inicializar os módulos
* `terraform plan` - Para verificar o que será provisionado
* `terraform apply` - Para provisionar de fato a infraestrutura

4. Agora basta esperar a infra subir e o script do user_data ser executado automaticamente. Pode demorar até 10 minutos para a aplicacão estar acessível pelo IP público ou DNS público.



