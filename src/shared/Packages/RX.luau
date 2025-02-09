type Observable = {
	subscribe: (
		self: Observable,
		onNext: (any) -> (),
		onError: ((any) -> ())?,
		onComplete: (() -> ())?
	) -> { unsubscribe: () -> (), isUnsubscribed: () -> boolean },
	map: (self: Observable, (any) -> any) -> Observable,
	filter: (self: Observable, (any) -> boolean) -> Observable,
	take: (self: Observable, number) -> Observable,
}

local RX = {}
RX.__index = RX

-- Observable constructor
function RX.new(subscribe): Observable
	local self = setmetatable({}, RX)
	self._subscribe = subscribe
	return self
end

-- Subscribe to the observable
function RX:subscribe(onNext, onError, onComplete)
	local subscription = {}
	subscription._isUnsubscribed = false

	function subscription:unsubscribe()
		self._isUnsubscribed = true
	end

	function subscription:isUnsubscribed()
		return self._isUnsubscribed
	end

	local safeOnNext = function(value)
		if not subscription:isUnsubscribed() then
			pcall(function()
				onNext(value)
			end)
		end
	end

	local safeOnError = function(err)
		if onError and not subscription:isUnsubscribed() then
			pcall(function()
				onError(err)
			end)
		end
	end

	local safeOnComplete = function()
		if onComplete and not subscription:isUnsubscribed() then
			pcall(onComplete)
		end
	end

	local status, err = pcall(function()
		self._subscribe(safeOnNext, safeOnError, safeOnComplete)
	end)

	if not status and onError then
		onError(err)
	end

	return subscription
end

-- Create an observable from values
function RX.of(...)
	local values = { ... }
	return RX.new(function(onNext, _, onComplete)
		for _, value in ipairs(values) do
			onNext(value)
		end
		if onComplete then
			onComplete()
		end
	end)
end

-- Operator: map (transforms emitted values)
function RX:map(transform)
	local source = self
	return RX.new(function(onNext, onError, onComplete)
		return source:subscribe(function(value)
			local success, result = pcall(transform, value)
			if success then
				onNext(result)
			else
				if onError then
					onError(result)
				end
			end
		end, onError, onComplete)
	end)
end

-- Operator: filter (emits values that pass a predicate)
function RX:filter(predicate)
	local source = self
	return RX.new(function(onNext, onError, onComplete)
		return source:subscribe(function(value)
			local success, result = pcall(predicate, value)
			if success and result then
				onNext(value)
			elseif not success then
				onError(result)
			end
		end, onError, onComplete)
	end)
end

-- Operator: take (takes the first n values then completes)
function RX:take(n)
	local source = self
	return RX.new(function(onNext, onError, onComplete)
		local count = 0
		return source:subscribe(function(value)
			if count < n then
				count = count + 1
				onNext(value)
				if count == n then
					onComplete()
				end
			end
		end, onError, onComplete)
	end)
end

-- Operator: merge (combines multiple streams)
function RX.merge(...)
	local sources = { ... }
	return RX.new(function(onNext, onError, onComplete)
		local completedCount = 0
		local totalSources = #sources

		for _, source in ipairs(sources) do
			source:subscribe(onNext, onError, function()
				completedCount = completedCount + 1
				if completedCount == totalSources then
					onComplete()
				end
			end)
		end
	end)
end

-- Operator: combineLatest (emits when all streams have emitted at least once)
function RX.combineLatest(...)
	local sources = { ... }
	return RX.new(function(onNext, onError, onComplete)
		local latestValues = {}
		local hasValue = {}
		local totalSources = #sources

		local function emitIfReady()
			for i = 1, totalSources do
				if not hasValue[i] then
					return
				end
			end
			onNext(latestValues)
		end

		for index, source in ipairs(sources) do
			source:subscribe(function(value)
				latestValues[index] = value
				hasValue[index] = true
				emitIfReady()
			end, onError, onComplete)
		end
	end)
end

-- Utility: interval (emits values at regular intervals)
function RX.interval(timeInterval)
	return RX.new(function(onNext)
		local count = 0
		while true do
			task.wait(timeInterval)
			onNext(count)
			count = count + 1
		end
	end)
end

return RX
