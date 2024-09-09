#!/bin/bash

# Função para verificar se o Docker está instalado
check_docker_installed() {
    if [ -x "$(command -v docker)" ]; then
        return 0  # Docker está instalado
    else
        return 1  # Docker não está instalado
    fi
}

# Função para instalar o Docker
install_docker() {
    # Remover pacotes conflitantes
    for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do
        sudo apt-get remove -y $pkg
    done

    # Atualizar pacotes e instalar dependências
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl

    # Criar o diretório para as chaves GPG do Docker
    sudo install -m 0755 -d /etc/apt/keyrings

    # Adicionar a chave GPG oficial do Docker
    sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    # Adicionar o repositório do Docker
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    # Atualizar a lista de pacotes novamente
    sudo apt-get update

    # Instalar Docker e seus componentes
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    # Adicionar o grupo Docker (caso ainda não exista)
    sudo groupadd docker

    # Adicionar o usuário atual ao grupo Docker
    sudo usermod -aG docker $USER

    # Aplicar a nova associação ao grupo sem precisar de logout
    newgrp docker

    # Ativar serviços do Docker
    sudo systemctl enable docker.service
    sudo systemctl enable containerd.service

    # Mensagem de sucesso
    echo "Instalação do Docker concluída com sucesso!"
}

# Função para desinstalar o Docker
uninstall_docker() {
    # Remover pacotes do Docker
    for pkg in docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin; do
        sudo apt-get remove -y $pkg
    done

    # Remover arquivos de configuração
    sudo rm -rf /var/lib/docker
    sudo rm -rf /etc/docker
    sudo rm /etc/apt/keyrings/docker.asc
    sudo rm /etc/apt/sources.list.d/docker.list

    echo "Docker foi desinstalado com sucesso!"
}

# Menu principal
menu() {
    echo "O que você deseja fazer?"
    echo "1 - Instalar Docker"
    echo "2 - Desinstalar Docker"
    echo "0 - Sair"
    read -p "Escolha uma opção: " choice

    case $choice in
        1)
            echo "Instalando Docker..."
            install_docker
            ;;
        2)
            echo "Desinstalando Docker..."
            uninstall_docker
            ;;
        0)
            echo "Saindo..."
            exit 0
            ;;
        *)
            echo "Opção inválida. Tente novamente."
            menu
            ;;
    esac
}

# Verificar se o Docker está instalado e exibir o menu
if check_docker_installed; then
    echo "Docker já está instalado no sistema."
    menu
else
    echo "Docker não está instalado."
    menu
fi
