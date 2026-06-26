import QtQuick
import org.kde.ksysguard.sensors as Sensors

// Reads live CPU, memory and temperature via the Plasma sensors framework.
// Loaded lazily by main.qml so a missing module degrades gracefully.
Item {
    readonly property real cpuUsage: cpuSensor.value || 0
    readonly property real ramUsage: ramTotal.value > 0
        ? Math.max(0, Math.min(100, ramUsed.value / ramTotal.value * 100))
        : 0
    // CPU temperature in °C. 0 means the sensor is unavailable on this machine,
    // in which case main.qml simply omits it from the stats line.
    readonly property real cpuTemp: tempSensor.value || 0

    Sensors.Sensor {
        id: cpuSensor
        sensorId: "cpu/all/usage"
        updateRateLimit: 1500
    }

    Sensors.Sensor {
        id: ramUsed
        sensorId: "memory/physical/used"
        updateRateLimit: 1500
    }

    Sensors.Sensor {
        id: ramTotal
        sensorId: "memory/physical/total"
        updateRateLimit: 5000
    }

    Sensors.Sensor {
        id: tempSensor
        sensorId: "cpu/all/averageTemperature"
        updateRateLimit: 2000
    }
}
