#include "bluetooth.h"

static uint8_t input_buffer[64];
static uint8_t output_buffer[64];

static uint8_t mode;

volatile bool uart_data_waiting = false;

// Bluetooth inicijalizacija
void bluetooth_init() {
    uart_init(UART_ID, BAUD_RATE);
    gpio_set_function(UART_TX_PIN, GPIO_FUNC_UART);
    gpio_set_function(UART_RX_PIN, GPIO_FUNC_UART);
    uart_set_fifo_enabled(UART_ID, true);
    int UART_IRQ = UART_ID == uart0 ? UART0_IRQ : UART1_IRQ;
    
    irq_set_exclusive_handler(UART_IRQ, uart_triggered);
    irq_set_enabled(UART_IRQ, true);
    uart_set_irq_enables(UART_ID, true, false);

    for(int i = 0; i < 32; i++) {
        while (!uart_is_writable(UART_ID));
        uart_putc(UART_ID, 0);
    }
    
}

// Označi da postoji nova poruka
void uart_triggered() {
    uart_data_waiting = true;
}

void response() {
    gpio_put(25, uart_data_waiting);
    motor_driver(input_buffer[1]);
    switch (input_buffer[0]) {
    case 0:
        // neutral
        break;
    case 1:
        // ultrasonic_module
        ultrasonic_module_reaction();
        bluetooth_send();
        break;
    case 2:
        // matrix_module
        matrix_module_reaction();
        break;
    case 3:
        // ID nije korišten
        break;
    case 4:
        // ID nije korišten
        break;
    case 5:
        // ID nije korišten
        break;
    case 6:
        // ID nije korišten        
        break;
    case 7:
        // demo_module
        demo_module_reaction();
        break;
    case 18:
        // rescan
        scan_for_modules();
        send_return_message();
        break;
    case 19:
        // Promjena modula
        set_module_id(input_buffer[2]);
        module_setup(input_buffer[2]);
        break;
    default:
        break;
    }
}

// Odgovor na prekid
void bluetooth_recieve() {
    while(!uart_is_readable(UART_ID));
    while(uart_getc(UART_ID) != 254);

    for (int i = 0; i < 64; i++) {
        while (!uart_is_readable(UART_ID));
        input_buffer[i] = uart_getc(UART_ID);
    }

    uart_data_waiting = false;
}


// Pošalji poruku
void bluetooth_send() {
    while (!uart_is_writable(UART_ID));
    uart_putc(UART_ID, 254);
    for(int i = 0; i < 64; i++) {
        while (!uart_is_writable(UART_ID));
        uart_putc(UART_ID, output_buffer[i]);
    }
}

uint8_t* get_input_buffer() {
    return input_buffer;
}

uint8_t* get_output_buffer() {
    return output_buffer;
}

// Vrati poruku vezana za rescan
void send_return_message() {
    output_buffer[0] = 17;
    uint8_t *connected_modules = get_connected_modules();
    output_buffer[1] = get_number_of_modules();

    for(int i = 0; i<output_buffer[1]; i++) {
        output_buffer[2 + i] = connected_modules[i];
    }
    bluetooth_send();
}
