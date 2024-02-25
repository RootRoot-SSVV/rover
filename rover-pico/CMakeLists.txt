cmake_minimum_required(VERSION 3.13)

include(pico_sdk_import.cmake)
project(rover-pico C CXX ASM)

set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)

pico_sdk_init()

add_executable(main
src/main.c
src/bluetooth.c
src/system_manager.c
src/demo_module.c
src/ultrasonic_module.c
src/matrix_module.c
)

pico_enable_stdio_usb(main 1)
pico_enable_stdio_uart(main 1)

target_link_libraries(main pico_stdlib hardware_pwm hardware_gpio hardware_spi hardware_timer pico_multicore)

pico_add_extra_outputs(main)
