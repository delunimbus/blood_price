local spell, super = Class(Spell, "snowgrave")

function spell:init()
    super.init(self)

    -- Display name
    self.name = "SnowGrave"
    -- Name displayed when cast (optional)
    self.cast_name = nil

    -- Battle description
    self.effect = "Fatal"
    -- Menu description
    self.description = "Deals the fatal damage to\nall of the enemies."

    -- TP cost
    self.cost = 200
    --self.blood_price_cost = -20   --Flat HP cost. THIS TAKES PREDCENDECE, SO BE SURE TO SET IT TO 0 (default) IF YOU USE THE MAX HP TABLE!
    --local bp = 
    self.blood_price_max_hp = {     --Use this instead to make blood price based on max hp
        ["numerator"] = 1,          --Should default to 1
        ["denominator"] = 2         --Should default to 1
    }
    
    -- Target mode (ally, party, enemy, enemies, or none)
    self.target = "enemies"

    -- Tags that apply to this spell
    self.tags = {"ice", "fatal", "damage"}
end

function spell:getTPCost(chara)
    local cost = super.getTPCost(self, chara)
    if chara and chara:checkWeapon("thornring") then
        cost = Utils.round(cost / 2)
    end
    return cost
end

function spell:onCast(user, target)
    local object = SnowGraveSpell(user)
    object.damage = self:getDamage(user, target)
    object.layer = BATTLE_LAYERS["above_ui"]
    Game.battle:addChild(object)

    return false
end

function spell:getDamage(user, target)
    return math.ceil((user.chara:getStat("magic") * 40) + 600)
end

return spell