---v41.78 Fitness Action gives XP without animation and doesn't stop
---Reproduction Steps: start exercise, sprint, click ok (multiple times) to start the exercise while sprinting
---character gets the ExerciseEnded variable but never stops the action because the animation doesn't trigger an event with parameter FitnessFinished=TRUE

require "TimedActions/ISFitnessAction"
local _fitnessUpdate = ISFitnessAction.update
function ISFitnessAction:update()
    if self.character:getVariableBoolean("ExerciseEnded") then
        self:forceStop()
    else
        _fitnessUpdate(self)
    end
end
