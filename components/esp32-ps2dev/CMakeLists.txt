idf_component_register(
    SRCS "src/esp32-ps2dev.cpp"
    INCLUDE_DIRS "src"
    REQUIRES arduino nvs_flash
)
