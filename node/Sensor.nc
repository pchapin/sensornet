
interface Sensor {

    // Starts the process of reading the sensor.
    // The corresponding event is not signaled if an error occurs. Data is just lost.
    command void read_sensor( );

    // Signaled when the reading is complete.
    // If an error reading occurs, this event never happens.
    event void sensor_done( uint16_t value );
}
