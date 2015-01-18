package kalakuh.ttt
{
	import flash.geom.Point;
	
	/**
	 * ...
	 * @author Kalakuh
	 */
	public class AI 
	{
		/**
		 * calculates which is the best move for the next turn
		 * @param	marks	array that contains marks
		 * @param	type	type of AI's mark
		 * @return	Point that contains the position of next move
		 */
		public static function nextMove (marks : Vector.<Mark>, type : int) : Point {
			var pointValues : Object = new Object(); // Object (technically, a Map) for containing the values of the points
			var priorities : Object = new Object(); // A map for containing the priority of the points
			var highestPriority : uint = 0; // Contains the highest priority out of all tiles
			
			// set each point's value to its type, and its priority to 0
			for each (var mark : Mark in marks) {
				pointValues[mark.getX() + "|" + mark.getY()] = mark.getType();
				priorities[mark.getX() + "|" + mark.getY()] = 0;
			}
			
			// for each mark, check the cells which are in the range of 4 cells
			for each (var m : Mark in marks) {
				// 3 arrays, containing 8 values; 1 for each direction
					// do we continue checking to that direction
				var cont : Vector.<Boolean> = new <Boolean>[true, true, true, true, true, true, true, true];
					// what is the priority of each direction
				var priority : Vector.<uint> = new <uint>[1, 1, 1, 1, 1, 1, 1, 1];
					// maps that contain the values of the cells that don't contain a mark in each direction
				var directionPointValues : Vector.<Object> = new < Object > [ { }, { }, { }, { }, { }, { }, { }, { } ];
				
				// for loop for checking cells in the range from 1 to 4
				for (var r : uint = 1; r <= 4; r++) {
					// check cells in each direction
					for (var dir : uint = 0; dir < 8; dir++) {
						// if we continue checking to current direction
						if (cont[dir]) {
							// check the cell and get the result; 0 = enemy mark, 1 = own mark & 2 = empty
							
							// a graph for explaining variables x and y
							// m = position of the mark
							// numbers around it mean the direction
							// ====================================
							// 	x -1 0  1
							//  y| -- -- --
							//  1| 0  1  2
							//  0| 7  m  3
							// -1| 6  5  4
							var x : int = (r * ((dir == 0 || dir >= 6) ? -1 : (dir == 1 || dir == 5) ? 0 : 1));
							var y : int = (r * (dir < 3 ? 1 : ((dir == 3 || dir == 7) ? 0 : -1)))
							
							// get result
							var result : uint = checkPoint(directionPointValues[dir], pointValues, m.getX() + x, m.getY() + y, m.getType(), r, type);
							
							// cell contained different type of mark we used in checking - can't make a line to that row, so priority is 0
							if (result == 0) {
								cont[dir] = false;
								priority[dir] = 0;
							} else if (result == 1) { // cell contained same type of mark we used in checking, so it's more important
								priority[dir]++;
							}
						}
					}
				}
				
				// each line in range is now checked, now we add tiles to global pointValues Map
				for (var n : uint = 0; n < directionPointValues.length; n++) {
					var o : Object = directionPointValues[n];
					// for each 'key' in the Map
					for (var dirKey : String in o) {
						// add more value to the cell
						if (!pointValues[dirKey]) {
							pointValues[dirKey] = o[dirKey];
						} else {
							pointValues[dirKey] += o[dirKey];
						}
						// set priority of the cell
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
			
			// array to contain cells with best values
			var bestPoints : Vector.<Point> = new <Point>[];
			var bestScore : int = 0;
			
			// find the best cells with the highest priority
			for (var key : String in pointValues) {
				if (priorities[key] == highestPriority) {
					var split : Array;
					if (pointValues[key] > bestScore) {
						bestScore = pointValues[key];
						split = key.split("|");
						bestPoints = new <Point>[new Point(parseInt(split[0]), parseInt(split[1]))];
					} else if (pointValues[key] == bestScore) {
						split = key.split("|");
						bestPoints = new <Point>[new Point(parseInt(split[0]), parseInt(split[1]))];
					}
				}
			}
			// return a random best point
			if (bestPoints.length != 0) {
				return bestPoints[Math.floor(Math.random() * bestPoints.length)];
			} else { // there were no points, so we return a random point
				return new Point(Math.floor(Math.random() * 5), Math.floor(Math.random() * 5));
			}
		}
		
		
		private static function checkPoint (dirPoints : Object, allPoints : Object, x : int, y : int, type : int, iter : uint, playerType : int) : uint {
			// does the cell contain a mark
			if (allPoints[x + "|" + y] < 0) {
				if (allPoints[x + "|" + y] == type) {
					return 1;
				} else {
					return 0;
				}
			}
			// change these values to balance AI's aggresivity
			if (!dirPoints[x + "|" + y]) {
				dirPoints[x + "|" + y] = type == playerType ? 2 : 1;
			} else {
				dirPoints[x + "|" + y] += type == playerType ? 2 : 1;
			}
			// add some value to the cell based on the distance
			dirPoints[x + "|" + y] += (5 - iter) * (type != playerType ? 4 : 1);
			return 2;
		}
	}
}