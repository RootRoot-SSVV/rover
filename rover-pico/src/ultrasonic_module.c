#include "ultrasonic_module.h"
#include "pico/multicore.h"

//component    gpio
//TRIG         0
//ECHO         1

void init_ultrasonic_module() {
    gpio_set_dir(TRIG, GPIO_OUT);
    gpio_set_dir(ECHO, GPIO_IN);
    gpio_set_dir(25, GPIO_OUT);
}

volatile int shared_distance = 0;

uint32_t pulseIn(uint gpio, uint level, uint32_t timeout) {
    // Označi početnio vrijeme
    absolute_time_t start_time = get_absolute_time();

    // Pričekaj da bude !level
    while (gpio_get(gpio) != level) {
        if (absolute_time_diff_us(start_time, get_absolute_time()) >= timeout) {
            return 0;
        }
    }

    // Označi početno vijeme pulsa
    absolute_time_t pulse_start_time = get_absolute_time();

    // Pričekaj da bude level
    while (gpio_get(gpio) == level) {
        if (absolute_time_diff_us(start_time, get_absolute_time()) >= timeout) {
            return 0;
        }
    }
    // Označi vrijeme kraja pulsa
    absolute_time_t pulse_end_time = get_absolute_time();

    // Izračunaj razliku vremena
    uint32_t pulse_duration = absolute_time_diff_us(pulse_start_time, pulse_end_time);

    return pulse_duration;
}

int get_distance() {
    // Započni puls
    gpio_put(TRIG, 0);
    sleep_us(2);
    gpio_put(TRIG, 1);
    sleep_us(10);
    gpio_put(TRIG, 0);

    // Izmjeri vrijeme
    uint32_t duration = pulseIn(ECHO, 1, 10000);

    // Izračunaj udaljenost
    int distance = (duration * 0.0343) / 2.0;

    return distance;
}

// Spremi udajenost u listu slanja
void ultrasonic_module_reaction() {
    uint8_t *message = get_input_buffer();
    get_output_buffer()[0] = 1;

    int distance = get_distance();

    get_output_buffer()[1] = distance;
    get_output_buffer()[2] = 0; 
}

