/// Módulo para criar um NFT de exemplo com Display Padrão.
module sui_nft_test::meu_nft {

    // --- Importando Ferramentas (Dependencies) ---
    use sui::display;
    use std::string::{Self, String};
    use sui::package::{Self, Publisher};
    use sui::transfer;
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};

    // --- Estruturas de Dados ---

    /// One-Time Witness (Testemunha Única) para provar a autoria na inicialização.
    public struct MEU_NFT has drop {}

    /// Estrutura Principal do NFT.
    public struct MeuNFT has key, store {
        id: UID,           // Identidade única (como RG do NFT)
        name: String,      // Nome do NFT
        description: String, // Descrição do NFT
        url: String        // Link para a imagem
    }

    // --- Função de Inicialização ---
    // Roda apenas uma vez quando o contrato é publicado.
    fun init(otw: MEU_NFT, ctx: &mut TxContext) {
        let publisher = package::claim(otw, ctx);
        transfer::public_transfer(publisher, tx_context::sender(ctx));
    }

    // --- Função para Criar (Mintar) NFT ---
    entry fun mint(
        name: vector<u8>,        // Nome como lista de bytes
        description: vector<u8>, // Descrição como lista de bytes
        url: vector<u8>,         // URL como lista de bytes
        ctx: &mut TxContext      // Contexto da transação
    ) {
        let nft = MeuNFT {
            id: object::new(ctx),
            name: string::utf8(name),
            description: string::utf8(description),
            url: string::utf8(url),
        };
        transfer::public_transfer(nft, tx_context::sender(ctx));
    }

    // --- Função para Criar Display ---
    // Define como o NFT aparece nas carteiras.
    entry fun create_display(
        publisher: &Publisher,   // Prova de que você é o criador
        ctx: &mut TxContext
    ) {
        let mut display = display::new_with_fields<MeuNFT>(
            publisher,
            vector[
                string::utf8(b"name"),
                string::utf8(b"description"),
                string::utf8(b"image_url")
            ],
            vector[
                string::utf8(b"{name}"),
                string::utf8(b"{description}"),
                string::utf8(b"{url}")
            ],
            ctx
        );

        display::update_version(&mut display);
        transfer::public_transfer(display, tx_context::sender(ctx));
    }
}