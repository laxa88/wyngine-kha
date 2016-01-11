package wyn.manager;

import kha.input.Sensor;
import kha.input.SensorType;

class WynSensor extends WynManager
{
	public static var accelX:Float = 0;
	public static var accelY:Float = 0;
	public static var accelZ:Float = 0;
	public static var gyroX:Float = 0;
	public static var gyroY:Float = 0;
	public static var gyroZ:Float = 0;

	public function new ()
	{
		super();

		var accelero = Sensor.get(SensorType.Accelerometer);
		var gyro = Sensor.get(SensorType.Gyroscope);

		if (accelero != null) accelero.notify(onAccelero);
		if (gyro != null) gyro.notify(onGyro);
	}

	function onAccelero (x:Float, y:Float, z:Float)
	{
		accelX = x;
		accelY = y;
		accelZ = z;
	}

	function onGyro (x:Float, y:Float, z:Float)
	{
		gyroX = x;
		gyroY = y;
		gyroZ = z;
	}
}