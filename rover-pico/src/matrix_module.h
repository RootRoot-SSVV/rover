#include "pico/stdlib.h"
#include "hardware/spi.h"
#include "bluetooth.h"


#ifndef MATRIX_MODULE_H_
#define MATRIX_MODULE_H_

// Pico     Matrix
// CSn  --  CS
// SCK  --  CLK
// TX   --  DIN

#define DIN 3
#define CS 5
#define CLK 2
#define SPI_PORT spi0

void init_matrix_module();
void max7219_send(uint8_t reg, uint8_t data);
void set_led(int x, int y, bool state);
void display_pattern(uint8_t *pattern);
void matrix_module_reaction();

#endif // MATRIX_MODULE_H_