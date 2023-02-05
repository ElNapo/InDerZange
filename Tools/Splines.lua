Splines = {}

function Splines.GetSplineByData( tData, xData)
	local N = table.getn(tData)
	-- prepare the matrix and vector needed for the linear problem
	local matrixPart = Matrix.BuildZeroMatrix( 4*N-4, 4*N-4)
	local vectorPart = {}
	for j = 1, 4*N-4 do
		vectorPart[j] = 0
	end
	vectorPart = Vector.New(vectorPart)
	-- now encode the conditions
	
end
Splines.BezierBases = {
	[1] = function(_lambda) return (1-_lambda)*(1-_lambda)*(1-_lambda) end,
	[2] = function(_lambda) return 3*_lambda*(1-_lambda)*(1-_lambda) end,
	[3] = function(_lambda) return 3*_lambda*_lambda*(1-_lambda) end,
	[4] = function(_lambda) return _lambda*_lambda*_lambda end
}
function Splines.GetBezierCurve(_p1, _p2, _p3, _p4)
	return function( _lambda)
		local coeff1, coeff2, coeff3, coeff4 = Splines.BezierBases[1](_lambda), Splines.BezierBases[2](_lambda), Splines.BezierBases[3](_lambda), Splines.BezierBases[4](_lambda)
		return {X = coeff1*_p1.X + coeff2*_p2.X + coeff3*_p3.X + coeff4*_p4.X, 
				Y = coeff1*_p1.Y + coeff2*_p2.Y + coeff3*_p3.Y + coeff4*_p4.Y}
	end
end