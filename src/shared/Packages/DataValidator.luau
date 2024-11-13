--[[ 
	The most important ones are:
	- `isNaN`: Checks if a value is `NaN`. Players often try to avoid type break systems by using `NaN` as a number.
	- `isInfinity`: Checks if a value is `math.huge`. Players often try to avoid type checks by using huge numbers (as infinity passes as number)
	- `isDescendantOf`: Checks if a value is a descendant (and is an instance) of a given ancestor. Players can spoof an instance by creating a fake table.

	```lua
	local DataValidator = require(Packages.DataValidator)

	local value = math.huge
	print(DataValidator.isInfinity(value)) -- true

	local value = "Hello, World!"
	local validator = DataValidator.new(value)
	print(validator:isString()) -- true
	```
]]

local DataValidator = {}
DataValidator.__index = DataValidator


type DataValidator = {
	input: any,
	isNaN: () -> boolean,
	isInfinity: () -> boolean,
	isNumber: () -> boolean,
	isString: () -> boolean,
	isFunction: () -> boolean,
	isInstance: () -> boolean,
	isInRange: (min: number, max: number) -> boolean,
	isNonEmptyString: () -> boolean,
	isValidTable: () -> boolean,
	isBoolean: () -> boolean,
	matchesPattern: (pattern: string) -> boolean,
	isTruthy: () -> boolean,
	isFalsy: () -> boolean,
	isPositiveNumber: () -> boolean,
	isNegativeNumber: () -> boolean,
	isInteger: () -> boolean,
	isDescendantOf: (ancestor: Instance) -> boolean,
}

function DataValidator.new(input: any): DataValidator
	local self = setmetatable({}, DataValidator)
	self.input = input
	return self
end

function DataValidator.isValueNaN(value: any): boolean
	return typeof(value) ~= "number" or value ~= value
end

function DataValidator:isNaN(): boolean
	return DataValidator.isValueNaN(self.input)
end

function DataValidator.isValueInfinity(value: any): boolean
	return typeof(value) == "number" and math.abs(value) == math.huge
end

function DataValidator:isInfinity(): boolean
	return DataValidator.isValueInfinity(self.input)
end

function DataValidator.isValueNumber(value: any): boolean
	return typeof(value) == "number"
end

function DataValidator:isNumber(): boolean
	return DataValidator.isValueNumber(self.input)
end

function DataValidator.isValueString(value: any): boolean
	return typeof(value) == "string"
end

function DataValidator:isString(): boolean
	return DataValidator.isValueString(self.input)
end

function DataValidator.isValueFunction(value: any): boolean
	return typeof(value) == "function"
end

function DataValidator:isFunction(): boolean
	return DataValidator.isValueFunction(self.input)
end

function DataValidator.isValueInstance(value: any): boolean
	return typeof(value) == "Instance"
end

function DataValidator:isInstance(): boolean
	return DataValidator.isValueInstance(self.input)
end

function DataValidator.isValueInRange(value: any, min: number, max: number): boolean
	return typeof(value) == "number" and value >= min and value <= max
end

function DataValidator:isInRange(min: number, max: number): boolean
	return DataValidator.isValueInRange(self.input, min, max)
end

function DataValidator.isValueNonEmptyString(value: any): boolean
	return typeof(value) == "string" and value ~= ""
end

function DataValidator:isNonEmptyString(): boolean
	return DataValidator.isValueNonEmptyString(self.input)
end

function DataValidator.isValueValidTable(value: any): boolean
	return typeof(value) == "table" and next(value) ~= nil
end

function DataValidator:isValidTable(): boolean
	return DataValidator.isValueValidTable(self.input)
end

function DataValidator.isValueBoolean(value: any): boolean
	return typeof(value) == "boolean"
end

function DataValidator:isBoolean(): boolean
	return DataValidator.isValueBoolean(self.input)
end

function DataValidator.valueMatchesPattern(value: any, pattern: string): boolean
	return typeof(value) == "string" and string.match(value, pattern) ~= nil
end

function DataValidator:matchesPattern(pattern: string): boolean
	return DataValidator.valueMatchesPattern(self.input, pattern)
end

function DataValidator.isValueTruthy(value: any): boolean
	return value ~= nil and value ~= false
end

function DataValidator:isTruthy(): boolean
	return DataValidator.isValueTruthy(self.input)
end

function DataValidator.isValueFalsy(value: any): boolean
	return value == nil or value == false
end

function DataValidator:isFalsy(): boolean
	return DataValidator.isValueFalsy(self.input)
end

function DataValidator.isValuePositiveNumber(value: any): boolean
	return typeof(value) == "number" and value > 0
end

function DataValidator:isPositiveNumber(): boolean
	return DataValidator.isValuePositiveNumber(self.input)
end

function DataValidator.isValueNegativeNumber(value: any): boolean
	return typeof(value) == "number" and value < 0
end

function DataValidator:isNegativeNumber(): boolean
	return DataValidator.isValueNegativeNumber(self.input)
end

function DataValidator.isValueInteger(value: any): boolean
	return typeof(value) == "number" and value % 1 == 0
end

function DataValidator:isInteger(): boolean
	return DataValidator.isValueInteger(self.input)
end

function DataValidator.isValueDescendantOf(value: any, ancestor: Instance): boolean
	return typeof(value) == "Instance" and value:IsDescendantOf(ancestor)
end

function DataValidator:isDescendantOf(ancestor: Instance): boolean
	return DataValidator.isValueDescendantOf(self.input, ancestor)
end

return DataValidator
