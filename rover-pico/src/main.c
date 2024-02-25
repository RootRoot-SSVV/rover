#include <stdio.h>
#include "pico/stdlib.h"
#include "hardware/gpio.h"
#include "bluetooth.h"
#include "system_manager.h"


int main() {
    stdio_init_all();

    bluetooth_init();
    system_manager_init();
    bus_init();
    motor_init();

    gpio_init(25);
    gpio_set_dir(25, GPIO_OUT);

    while (1) {
        if(uart_triggered){
            bluetooth_recieve();
            response();
        }
    }
}
