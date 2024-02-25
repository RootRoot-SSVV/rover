#ifndef BLUETOOTH_H_
#define BLUETOOTH_H_

#include <stdlib.h>
#include "pico/stdlib.h"
#include "hardware/uart.h"
#include "hardware/gpio.h"

#include "system_manager.h"
#include "ultrasonic_module.h"
#include "demo_module.h"
#include "matrix_module.h"

#define UART_ID uart0
#define BAUD_RATE 115200 
// #define BAUD_RATE 9600
#define UART_TX_PIN 16
#define UART_RX_PIN 17

void bluetooth_init();
void response();
void bluetooth_recieve();
void bluetooth_send();
uint8_t* get_input_buffer();
uint8_t* get_output_buffer();
void send_return_message();
void uart_triggered();
bool get_uart_triggered();

#endif // BLUETOOTH_H_