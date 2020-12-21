const oracleContract = artifacts.require('./Oracle');
const Consumer = artifacts.require('./APIConsumer');
let config = require('../config');
const {BN, constants, expectEvent, expectRevert} = require(
    'openzeppelin-test-helpers');
const {expect} = require('chai');
const Controller = artifacts.require('Controller');
const Vault = artifacts.require('Vault');
const NoopStrategy = artifacts.require('NoopStrategy');
const Storage = artifacts.require('Storage');
const underlying = config.kovanOraiToken;
const usdtToken = config.kovanUSDTToken;

contract('Controller Deploy', function(accounts) {
    console.log(accounts);
    describe('Test', function() {
        let governance = accounts[0];
        let rewardCollector = accounts[1];
        console.log('governance: ', governance);
        console.log('rewardCollector ', rewardCollector);

        let strategy;
        let futureStrategy;
        let storage;
        let vault;
        let controller;
        let oracle;
        let consumer;
        beforeEach(async function() {
            // set up controller
            storage = await Storage.new({from: governance});
            console.log('storage address: ', storage.address);
            controller = await Controller.new(storage.address, rewardCollector,
                {
                    from: governance,
                });
            console.log('controller address: ', controller.address);
            await storage.setController(controller.address, {from: governance});

            vault = await Vault.new({
                from: governance,
            });
            console.log('vault  address: ', vault.address);
            // const vaultAsProxy = await VaultProxy.new(vaultImplementation.address,
            //     fromParameter);
            // console.log('vault proxy address: ', vaultAsProxy.address);
            //
            // const vault = await Vault.at(vaultAsProxy.address);
            await vault.initializeVault(storage.address, usdtToken, 100,
                100, {
                    from: governance,
                });
            console.log('initializeVault params : ', storage.address,
                usdtToken);

            // set up the strategy
            strategy = await NoopStrategy.new(
                storage.address,
                usdtToken,
                vault.address,
                {from: governance},
            );
            console.log('strategy address: ', strategy.address);
            oracle = await oracleContract.new(underlying);
            console.log('oracle address:', oracle.address);
            await controller.setOracleAddress(oracle.address);
            console.log('Set oracle address complete');
            consumer = await Consumer.new(oracle.address, underlying);
            console.log('consumer address:', oracle.address);
            await consumer.setRequesterPermission(controller.address, 'true');
            console.log('Set requester permission ok');
            futureStrategy = await NoopStrategy.new(
                controller.address,
                usdtToken,
                vault.address,
                {from: governance},
            );
            console.log('another strategy address: ',
                futureStrategy.address);
        }, 30000000);

        it('Controller can add vault and strategy', async function() {
            // The vault does not exist before the strategy is added
            assert.isFalse(await controller.vaults(vault.address));

            assert.equal(await vault.strategy(), constants.ZERO_ADDRESS);

            // adding the vault and strategy pair
            await controller.addVaultAndStrategy(vault.address,
                strategy.address);
            console.log('controller addVaultAndStrategy:', vault.address, ' ',
                strategy.address);
            // should have successfully set them
            assert.isTrue(await controller.vaults(vault.address));

            assert.equal(await vault.strategy(), strategy.address);

            console.log('end testing\n');
            console.log('Result\n');
            console.log('config.storage="' + storage.address + '"');
            console.log('config.controller="' + controller.address + '"');
            console.log('config.vault="' + vault.address + '"');
            console.log('config.currentStrategy="' + strategy.address + '"');
            console.log(
                'config.futureStrategy="' + futureStrategy.address + '"');
            console.log('config.oracleAddress="' + oracle.address + '"');
            console.log('config.consumerAddress="' + consumer.address + '"');

        });
    });
});
