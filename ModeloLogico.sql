
SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- Criação do schema
CREATE SCHEMA IF NOT EXISTS `mydb` DEFAULT CHARACTER SET utf8;
USE `mydb`;

-- Tabela Categoria
CREATE TABLE IF NOT EXISTS `Categoria` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `nome` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`id`)
);

-- Tabela Subcategoria
CREATE TABLE IF NOT EXISTS `Subcategoria` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `nome` VARCHAR(100) NOT NULL,
  `id_categoria` INT NOT NULL,
  PRIMARY KEY (`id`),
  INDEX (`id_categoria`),
  CONSTRAINT `fk_Subcategoria_Categoria`
    FOREIGN KEY (`id_categoria`) REFERENCES `Categoria` (`id`)
);

-- Tabela Produto
CREATE TABLE IF NOT EXISTS `Produto` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `nome` VARCHAR(100) NOT NULL,
  `descricao` TEXT DEFAULT NULL,
  `preco` DECIMAL(10,2) NOT NULL,
  `estoque` INT NOT NULL,
  `id_subcategoria` INT NOT NULL,
  `id_rfid` VARCHAR(50) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE (`id_rfid`),
  INDEX (`id_subcategoria`),
  CONSTRAINT `fk_Produto_Subcategoria`
    FOREIGN KEY (`id_subcategoria`) REFERENCES `Subcategoria` (`id`)
);

-- Tabela RFID
CREATE TABLE IF NOT EXISTS `RFID` (
  `id` VARCHAR(50) NOT NULL,
  `id_produto` INT NOT NULL,
  `data_registro` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `status` ENUM('ativo', 'inativo') DEFAULT 'ativo',
  `ultima_leitura` DATETIME DEFAULT NULL,
  PRIMARY KEY (`id`),
  INDEX (`id_produto`),
  CONSTRAINT `fk_RFID_Produto`
    FOREIGN KEY (`id_produto`) REFERENCES `Produto` (`id`)
);

-- Tabela Cliente
CREATE TABLE IF NOT EXISTS `Cliente` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `nome` VARCHAR(50) NOT NULL,
  `email` VARCHAR(100) NOT NULL,
  `telefone` VARCHAR(20) DEFAULT NULL,
  `id_endereco_padrao` INT DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE (`email`),
  INDEX (`id_endereco_padrao`)
);

-- Tabela Endereco
CREATE TABLE IF NOT EXISTS `Endereco` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `id_cliente` INT NOT NULL,
  `tipo` VARCHAR(50) DEFAULT NULL,
  `cidade` VARCHAR(100) NOT NULL,
  `cep` VARCHAR(10) DEFAULT NULL,
  `linha_endereco1` VARCHAR(100) NOT NULL,
  `linha_endereco2` VARCHAR(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  INDEX (`id_cliente`),
  CONSTRAINT `fk_Endereco_Cliente`
    FOREIGN KEY (`id_cliente`) REFERENCES `Cliente` (`id`)
);

-- Agora que Endereco já existe, adiciona FK em Cliente
ALTER TABLE `Cliente`
  ADD CONSTRAINT `fk_Cliente_Endereco`
  FOREIGN KEY (`id_endereco_padrao`) REFERENCES `Endereco` (`id`);

-- Tabela Venda
CREATE TABLE IF NOT EXISTS `Venda` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `id_cliente` INT NOT NULL,
  `data_hora` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `status_pagamento` ENUM('pendente', 'concluido', 'cancelado') DEFAULT 'pendente',
  PRIMARY KEY (`id`),
  INDEX (`id_cliente`),
  CONSTRAINT `fk_Venda_Cliente`
    FOREIGN KEY (`id_cliente`) REFERENCES `Cliente` (`id`)
);

-- Tabela ItemVenda
CREATE TABLE IF NOT EXISTS `ItemVenda` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `id_venda` INT NOT NULL,
  `id_produto` INT NOT NULL,
  `quantidade` INT NOT NULL,
  `id_rfid` VARCHAR(50) DEFAULT NULL,
  PRIMARY KEY (`id`),
  INDEX (`id_venda`),
  INDEX (`id_produto`),
  INDEX (`id_rfid`),
  CONSTRAINT `fk_ItemVenda_Venda`
    FOREIGN KEY (`id_venda`) REFERENCES `Venda` (`id`),
  CONSTRAINT `fk_ItemVenda_Produto`
    FOREIGN KEY (`id_produto`) REFERENCES `Produto` (`id`),
  CONSTRAINT `fk_ItemVenda_RFID`
    FOREIGN KEY (`id_rfid`) REFERENCES `RFID` (`id`)
);

-- Tabela HistoricoStatusVenda
CREATE TABLE IF NOT EXISTS `HistoricoStatusVenda` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `id_venda` INT NOT NULL,
  `mudanca_status` ENUM('pendente', 'concluido', 'cancelado') NOT NULL,
  `data_hora` DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX (`id_venda`),
  CONSTRAINT `fk_HistoricoStatusVenda_Venda`
    FOREIGN KEY (`id_venda`) REFERENCES `Venda` (`id`)
);

-- Restaura configurações anteriores
SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
