package kalakuh.ttt
{
	import flash.geom.Point;
	
	/**
	 * ...
	 * @author Kalakuh
	 */
	public class AI 
	{
		public static function nextMove (marks : Vector.<Mark>, type : int) : Point {
			var points : Object = new Object();
			var priorities : Object = new Object();
			var highestPriority : uint = 0;
			
			for each (var mark : Mark in marks) {
				points[mark.getX() + "|" + mark.getY()] = mark.getType();
				priorities[mark.getX() + "|" + mark.getY()] = 0;
			}
			
			for each (var m : Mark in marks) {
				var cont : Vector.<Boolean> = new <Boolean>[true, true, true, true, true, true, true, true];
				var priority : Vector.<uint> = new <uint>[1, 1, 1, 1, 1, 1, 1, 1];
				var directionPoints : Vector.<Object> = new < Object > [ { }, { }, { }, { }, { }, { }, { }, { } ];
				for (var r : uint = 1; r <= 4; r++) {
					for (var dir : uint = 0; dir < 8; dir++) {
						if (cont[dir]) {
							var result : uint = checkPoint(directionPoints[dir], points, m.getX() + (r * ((dir == 0 || dir >= 6) ? -1 : (dir == 1 || dir == 5) ? 0 : 1)), m.getY() + (r * (dir < 3 ? 1 : ((dir == 3 || dir == 7) ? 0 : -1))), m.getType(), r, type);
							if (result == 0) {
								cont[dir] = false;
								priority[dir] = 0;
							} else if (result == 1) {
								priority[dir]++;
							}
						}
					}
				}
				for (var n : uint = 0; n < directionPoints.length; n++) {
					var o : Object = directionPoints[n];
					for (var dirKey : String in o) {
						if (!points[dirKey]) {
							points[dirKey] = o[dirKey];
						} else {
							points[dirKey] += o[dirKey];
						}
						if (!priorities[dirKey]) {
							priorities[dirKey] = priority[n];
							highestPriority = Math.max(highestPriority, priority[n]);
						} else {
							priorities[dirKey] = Math.max(priority[n], priorities[dirKey]);
							highestPriority = Math.max(highestPriority, priority[n]);
						}
					}
				}
			}
			
			var bestPoints : Vector.<Point> = new <Point>[];
			var bestScore : int = 0;
			
			for (var key : String in points) {
				if (priorities[key] == highestPriority) {
					var split : Array;
					if (points[key] > bestScore) {
						bestScore = points[key];
						split = key.split("|");
						bestPoints = new <Point>[new Point(parseInt(split[0]), parseInt(split[1]))];
					} else if (points[key] == bestScore) {
						split = key.split("|");
						bestPoints = new <Point>[new Point(parseInt(split[0]), parseInt(split[1]))];
					}
				}
				//trace(key + ": value " + points[key] + ", priority " + priorities[key]);
			}
			//trace(highestPriority);
			if (bestPoints.length != 0) {
				return bestPoints[Math.floor(Math.random() * bestPoints.length)];
			} else {
				return new Point(Math.floor(Math.random() * 5), Math.floor(Math.random() * 5));
			}
		}
		
		// 1 2 3
		// 8   4
		// 7 6 5
		
		private static function checkPoint (dirPoints : Object, allPoints : Object, x : int, y : int, type : int, iter : uint, playerType : int) : uint {
			if (allPoints[x + "|" + y] < 0) {
				if (allPoints[x + "|" + y] == type) {
					return 1;
				} else {
					return 0;
				}
			}
			
			if (!dirPoints[x + "|" + y]) {
				dirPoints[x + "|" + y] = type == playerType ? 2 : 1;
			} else {
				dirPoints[x + "|" + y] += type == playerType ? 2 : 1;
			}
			dirPoints[x + "|" + y] += (5 - iter) * (type != playerType ? 4 : 1);
			return 2;
		}
	}
}