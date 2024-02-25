#include "system_manager.h"
#include "bluetooth.h"
#include "demo_module.h"
#include "matrix_module.h"

uint8_t connected_modules[8];
volatile uint8_t number_of_modules;
volatile uint8_t selected_module;

// inicijalizira početna stanja
void system_manager_init() {
    selected_module = 16;
    number_of_modules = 0;
}

void module_setup(int id) {
    switch (id) {
    case 1:
        init_ultrasonic_module();
        break;
    case 2:
        init_matrix_module();
        break;
    case 3:
        // modul s id 3
        break;
    case 4:
        // modul s id 4
        break;
    case 5:
        // modul s id 5
        break;
    case 6:
        // modul s id 6
        break;
    case 7:
        init_demo_module();
        break;
    default:
        break;
    }
}

void bus_init() {
    // 0 - 11       -> data for module
    // 12           -> module is connected>
    // 13, 14, 15   -> module selector

    for(int i = 0; i <= 11; i++) {
        gpio_init(i);
        gpio_set_dir(i, GPIO_OUT);
    }

    gpio_init(10);
    gpio_set_dir(10, GPIO_IN);

    for (int i = 13; i < 16; i++) {
        gpio_init(i);
        gpio_set_dir(i, GPIO_OUT);
    }
}

// Promjeni modul
void set_module_id(uint8_t id) {
    selected_module = id;
    gpio_put(13, id & 1);
    gpio_put(14, id & 2);
    gpio_put(15, id & 4);

}

// Mijenjanjem broja na sabirnici pretraži module
void scan_for_modules() {

    number_of_modules = 0;

    for (int i = 1; i < 8; i++) {
        gpio_put(13, i & 1);
        gpio_put(14, i & 2);
        gpio_put(15, i & 4);

        sleep_ms(100);

        if(gpio_get(10)) {
            connected_modules[number_of_modules++] = i;
        }
    }
}

uint8_t* get_connected_modules() {
    return connected_modules;
}

uint8_t get_number_of_modules() {
    return number_of_modules;
}

void select_module(uint8_t mode) {
    selected_module = mode;

    gpio_put(12, mode & 1);
    gpio_put(13, mode & 2);
    gpio_put(14, mode & 4);

    // 
}

// Postavljanje pinova motora
void motor_init() {
    gpio_init(28);
    gpio_set_dir(28, GPIO_OUT);     // Stalno 1
    gpio_init(27);
    gpio_set_dir(27, GPIO_OUT);     // Stalno 1
    gpio_init(26);
    gpio_set_dir(26, GPIO_OUT);     // LPWM
    gpio_init(22);
    gpio_set_dir(22, GPIO_OUT);     // RPWM

    gpio_init(21);
    gpio_set_dir(21, GPIO_OUT);     // Stalno 1
    gpio_init(20);
    gpio_set_dir(20, GPIO_OUT);     // Stalno 1
    gpio_init(19);
    gpio_set_dir(19, GPIO_OUT);     // LPWM
    gpio_init(18);
    gpio_set_dir(18, GPIO_OUT);     // RPWM

    gpio_put(28, 1);
    gpio_put(27, 1);
    gpio_put(21, 1);
    gpio_put(20, 1);
}

// Ugasi / upali motor u određenom smjeru
void motor_driver(uint8_t motorInt) {
    uint8_t forward = motorInt & 1;
    uint8_t backward = motorInt & 2;
    uint8_t left = motorInt & 4;
    uint8_t right = motorInt & 8;

    if (forward) {
        gpio_put(22, 0);
        gpio_put(26, 1);

        gpio_put(18, 0);
        gpio_put(19, 1);
    } else if (backward) {
        gpio_put(26, 0);
        gpio_put(22, 1);

        gpio_put(19, 0);
        gpio_put(18, 1);
    } else if (right) {
        gpio_put(22, 0);
        gpio_put(26, 1);

        gpio_put(19, 0);
        gpio_put(18, 1);
    } else if (left) {
        gpio_put(26, 0);
        gpio_put(22, 1);

        gpio_put(18, 0);
        gpio_put(19, 1);
    } else {
        gpio_put(26, 0);
        gpio_put(22, 0);

        gpio_put(19, 0);
        gpio_put(18, 0);
    }
}