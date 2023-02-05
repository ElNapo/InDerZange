if mcbPacker then --mcbPacker.ignore
mcbPacker.require("s5CommunityLib/comfort/math/Vector")
mcbPacker.require("s5CommunityLib/comfort/table/CopyTable")
end --mcbPacker.ignore


--- author: Napo		
--- current maintainer: Napo		
--- current version: 0.1

-- Implements a matrix class and associated solver.
-- Scope: Support scalar matrix multiplication.			DONE - untested
--		  Support matrix matrix multiplication.			DONE - untested
--		  Support matrix vector multiplication.			DONE - untested
--		  Support simple row or column manipulation.	DONE
--		  Support simple solver.						DONE
--		  Give simple constructor for things like identity matrix and zero matrix of given size.	DONE

-- 
-- Requirements:
-- - Vector und all its requirements
-- - CopyTable
Matrix = {}

-- Arguments:
--	data: A table of tables of numbers. Each table has to have the same number of entries.
function Matrix.New(data)
	local nRow, nCol = Matrix.CheckRawData(data)
	local t = CopyTable(Matrix)
	t.data = data
	t.nRow = nRow
	t.nCol = nCol
	t.isMatrix = true
	setmetatable(t, Matrix.mt)
	return t
end

-- Internal, checks the validity of the argument given to the constructor. ALso gets the size of the matrix.
function Matrix.CheckRawData(data)
	-- first check if this thing is even a number
	assert( type(data) == "table", "Matrix.New: data has to be a table!")
	-- then check the actual entries
	local currLength
	local newLength
	for j = 1, table.getn(data) do
		assert( type(data[j]) == "table", "Matrix.New: Each element of data has to be a table!")
		-- guarantee that all elements have the same length
		newLength = table.getn(data[j])
		currLength = currLength or newLength
		assert( currLength == newLength, "Matrix.New: Each element of data has to have the same number of elements!")
		-- and that every entry is a number
		for k = 1, newLength do
			assert( type(newLength) == "number", "Matrix.New: Each element of an element of data has to be a number!")
		end
	end
	return table.getn(data), newLength
end

function Matrix.GetArgumentType(arg)
	if type(arg) == "number" then return "num" end
	if type(arg) == "string" then 
		if arg.isMatrix then return "mat" end
		return "vec"
	end
	return "?"
end

function Matrix.BuildIdentityMatrix(size)
	assert( type(size) == "num", "Size has to be a number!")
	local data = {}
	for j = 1, size do
		data[j] = {}
		for k = 1, size do
			data[j][k] = 0
		end
		data[j][j] = 1
	end
	return Matrix.New(data)
end

function Matrix.BuildZeroMatrix( nRow, nCol)
	local data = {}
	for j = 1, nRow do
		data[j] = {}
		for k = 1, nCol do
			data[j][k] = 0
		end
	end
	return Matrix.New(data)
end

function Matrix:Size()
	return self.nRow, self.nCol
end

-- TODO: Maybe add scalar matrix addition by replacing the scalar with scalar times identity?
function Matrix:Add(v)
	local nCol2, nRow2 = v:Size()
	assert(self.nRow == nRow2, "Matrix addition: The number of rows has to coincide!")
	assert(self.nCol == nCol2, "Matrix addition: The number of columns has to coincide!")
	local newd = {}
	for j = 1, nRow do
		newd[j] = {}
		for k = 1, nCol do
			newd[j][k] = self.data[j][k] + v[j][k]
		end
	end
	return Matrix.New(newd)
end

-- computes s * self
function Matrix:ScalarMultiplication(s)
	local newd = {}
	for j = 1, self.nRow do
		newd[j] = {}
		for k = 1, self.nCol do
			newd[j][k] = self.data[j][k] + v[j][k]
		end
	end
	return Matrix.New(newd)
end

-- computes self * v
function Matrix:VectorMultiplication(v) -- this one is scary a.f., which meta table will be used?
	assert( self.nCol == v:Size(), "Matrix vector multiplication: Sizes do not work out!")
	local data = {}
	local singleEntry
	for j = 1, self.nRow do
		singleEntry = 0
		for k = 1, self.nCol do
			singleEntry = singleEntry + self.data[j][k] * v[k]
		end
		data[j] = singleEntry
	end
	return Vector.New(data)
end

function Matrix:MatrixMultiplication(m) -- computes self * m
	local nRow2, nCol2 = m:Size()
	assert( self.nCol == nRow2, "Matrix multiplication: Sizes do not allow multiplication!")
	local newd = {}
	local singleEntry
	for j = 1, self.nRow do
		newd[j] = {}
		for k = 1, nCol2 do
			singleEntry = 0
			for l = 1, self.nCol do
				singleEntry = singleEntry + self.data[j][l] * m[l][k]
			end
			newd[j][k] = singleEntry
		end
	end
	return Matrix.New(newd)
end

-- Manipulates the toSubRow.
-- self[toSubRow, :] = self[toSubRow, :] - multiplier*self[subbingRow, :]
function Matrix:SubRowFromRow( toSubRow, subbingRow, multiplier)
	for j = 1, self.nCol do
		self.data[toSubRow][j] = self.data[toSubRow][j] - multiplier*self.data[subbingRow][j] 
	end
end

-- Computes a solution x to the problem self*x = v
function Matrix:SolveProblem(v)
	-- just use gaussian elimination without pivoting, will hopefully be good enough
	-- general idea: Left-multiply matrices until self*x = v transforms to D*x = w where D is lower right triangular matrix
	-- then computing x is easy by backwards solving
	local D = Matrix.New(self.data) -- get new copy to apply manipulations to
	local w = Vector.New(v.data)
	local nRow, nCol = self:Size()
	local mult = 0
	for j = 1, nCol do
		assert(D[j][j] ~= 0, "Error during gaussian elimination: 0 on diagonal!")
		for k = j+1, nRow do
			mult = D[k][j]/D[j][j]
			D:SubRowFromRow( k, j, mult)
			w[k] = w[k] - mult*w[j]
		end
	end
	--LuaDebugger.Log(D.data)
	--LuaDebugger.Log(w.data)
	-- Results as expected :)
	
	-- Now backwards solving
	-- Prepare the answer
	local sol = {}
	for j = 1, nRow do
		sol[j] = 0
	end
	-- Actual backwards solving
	for j = nRow, 1, -1 do
		sol[j] = w[j]
		for k = j+1, nRow do
			sol[j] = sol[j] - D[j][k]*sol[k]
		end
		sol[j] = sol[j] / D[j][j]
		--LuaDebugger.Log(sol)
	end
	return Vector.New(sol)
end

Matrix.mt = {
	__add = function(a, b)
		return a:Add(b)
	end,
	__mul = function(a, b) 
		-- now this one is fun, either scalar*matrix, matrix*vector or matrix*matrix
		local typeA = Matrix.GetArgumentType(a)
		local typeB = Matrix.GetArgumentType(b)
		if typeA == "num" and typeB == "mat" then -- scalar matrix mult
			return b:ScalarMultiplication(a)
		elseif typeA == "mat" and typeB == "num" then -- matrix scalar mult
			return a:ScalarMultiplication(b)
		elseif typeA == "mat" and typeB == "vec" then	-- matrix vector mult
			return a:VectorMultiplication(b)
		elseif typeA == "mat" and typeB == "mat" then	-- matrix matrix mult
			return a:MatrixMultiplication(b)
		end
		assert( false, "Unknown type of multiplication!")
	end,
	__sub = function(a, b)
		return a + (-b)	-- forward to unm and add
	end,
	__unm = function(a)
		return -1 * a	-- forward to scalar mult
	end,
	__index = function(s, i)		-- allow numeric index acces to members, stolen from mcb.
		return rawget(s, "data")[i]
	end
}

