#include "matrix_module.h"

bool firstTurnOn = true;

static uint8_t led_matrix[8] = {0};

// Funkcija za slanje podataka pojedinačnom registru
void max7219_send(uint8_t reg, uint8_t data) {
    gpio_put(CS, 0); // Početak prijenosa
    spi_write_blocking(SPI_PORT, &reg, 1);
    spi_write_blocking(SPI_PORT, &data, 1);
    gpio_put(CS, 1); // Kraj prijenosa
}

// Inicijalizacija MAX7219
void init_matrix_module() {
    // Inicijalizacija SPI
    spi_init(SPI_PORT, 1000000); // SPI sat od 1 MHz
    gpio_set_function(DIN, GPIO_FUNC_SPI);
    gpio_set_function(CLK, GPIO_FUNC_SPI);
    gpio_init(CS);
    gpio_set_dir(CS, GPIO_OUT);

    // Inicijalizacija MAX7219
    max7219_send(0x0F, 0x00); 
    max7219_send(0x09, 0x00); 
    max7219_send(0x0B, 0x07);
    max7219_send(0x0C, 0x01);  
    max7219_send(0x0A, 0x0F); 

    if(firstTurnOn) {
        firstTurnOn = false;
        display_pattern((uint8_t[]){0, 0, 0, 0, 0, 0, 0, 0});
    }
}

void set_led(int x, int y, bool state) {
    // Izračunaj zrcalnu poziciju za x
    int mirrored_x = 7 - x;

    if (state) {
        // Postavi bit na zrcalnoj x poziciji
        led_matrix[y] |= (1 << mirrored_x);
    } else {
        // Očisti bit na zrcalnoj x poziciji
        led_matrix[y] &= ~(1 << mirrored_x);
    }

    // Pošalji ažurirano stanje reda LED matrici
    max7219_send(y + 1, led_matrix[y]);
}

// Funkcija za prikaz uzorka ili podataka na matrici
void display_pattern(uint8_t *pattern) {
    for (int i = 0; i < 8; i++) {
        max7219_send(i + 1, pattern[i]);
    }
}

void matrix_module_reaction() {
    // [način][id][prikaz][uzorak 1 - 8]
    //    0     1     2         3 - 11

    uint8_t *message = get_input_buffer();    
    display_pattern(&message[2]);
}
