// Adiciona a anotação #[test_module] para indicar que este é um módulo de teste.
#[test_module]
module sui_nft_test::sui_nft_test_tests {

    // Importa as funções e structs que vamos testar e usar no teste.
    use sui_nft_test::meu_nft::{Self, MeuNFT};
    use sui::test_scenario::{Self, TxContext};

    // --- CONSTANTES PARA O TESTE ---
    // Define endereços de usuários virtuais para o teste.
    const ALICE: address = @0xA;

    // --- TESTE 1: TESTAR A CRIAÇÃO (MINT) DO NFT ---

    // A anotação #[test] marca esta função como um teste individual.
    #[test]
    fun test_mint_success() {
        // 1. INICIA UM CENÁRIO DE TESTE
        // É como abrir um "simulador" de blockchain limpo.
        let mut scenario = test_scenario::begin(ALICE);

        // 2. PUBLICA O CONTRATO NO SIMULADOR
        // O `init` do seu módulo é chamado aqui.
        {
            test_scenario::publish_and_keep(&mut scenario, "sui_nft_test");
        };

        // 3. EXECUTA A FUNÇÃO QUE QUEREMOS TESTAR (MINT)
        // Simulamos que a usuária 'ALICE' está chamando a função `mint`.
        {
            let mut ctx = test_scenario::ctx(&mut scenario);
            meu_nft::mint(
                b"Meu NFT de Teste",
                b"Descricao do NFT de Teste",
                b"https://exemplo.com/imagem.png",
                &mut ctx
            );
        };

        // 4. VERIFICA O RESULTADO
        // A parte mais importante: checamos se o NFT foi criado corretamente
        // e se pertence à 'ALICE'.
        {
            // Pegamos o NFT que foi transferido para a carteira da ALICE.
            let nft: MeuNFT = test_scenario::take_from_sender(&scenario);

            // Verificamos se os dados do NFT são os que esperamos.
            assert!(nft.name == b"Meu NFT de Teste".to_string(), 1);
            assert!(nft.description == b"Descricao do NFT de Teste".to_string(), 2);
            assert!(nft.url == b"https://exemplo.com/imagem.png".to_string(), 3);

            // Descartamos o NFT para finalizar o teste.
            let MeuNFT { id, name: _, description: _, url: _ } = nft;
            sui::object::delete(id);
        };

        // 5. FINALIZA O CENÁRIO DE TESTE
        test_scenario::end(scenario);
    }
}