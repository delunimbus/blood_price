local lib = {}

------------------------------------------------------------------------------------
---Code between dashed lines are the custom code to insert in your respective hooks in your main mod scripts and what not.
------------------------------------------------------------------------------------

function lib:init()
    print("Loaded BloodPrice!")

    Utils.hook(BattleUI, "drawState", function(orig, self)
        if Game.battle.state == "MENUSELECT" then
            local page = math.ceil(Game.battle.current_menu_y / 3) - 1
            local max_page = math.ceil(#Game.battle.menu_items / 6) - 1

            local x = 0
            local y = 0
            Draw.setColor(Game.battle.encounter:getSoulColor())
            Draw.draw(self.heart_sprite, 5 + ((Game.battle.current_menu_x - 1) * 230), 30 + ((Game.battle.current_menu_y - (page*3)) * 30))

            local font = Assets.getFont("main")
            love.graphics.setFont(font)

            local page_offset = page * 6
            for i = page_offset+1, math.min(page_offset+6, #Game.battle.menu_items) do
                local item = Game.battle.menu_items[i]

                Draw.setColor(1, 1, 1, 1)
                local text_offset = 0
                -- Are we able to select this?
                local able = Game.battle:canSelectMenuItem(item)
                if item.party then
                    if not able then
                        -- We're not able to select this, so make the heads gray.
                        Draw.setColor(COLORS.gray)
                    end

                    for index, party_id in ipairs(item.party) do
                        local chara = Game:getPartyMember(party_id)

                        -- Draw head only if it isn't the currently selected character
                        if Game.battle:getPartyIndex(party_id) ~= Game.battle.current_selecting then
                            local ox, oy = chara:getHeadIconOffset()
                            Draw.draw(Assets.getTexture(chara:getHeadIcons() .. "/head"), text_offset + 30 + (x * 230) + ox, 50 + (y * 30) + oy)
                            text_offset = text_offset + 30
                        end
                    end
                end

                if item.icons then
                    if not able then
                        -- We're not able to select this, so make the heads gray.
                        Draw.setColor(COLORS.gray)
                    end

                    for _, icon in ipairs(item.icons) do
                        if type(icon) == "string" then
                            icon = {icon, false, 0, 0, nil}
                        end
                        if not icon[2] then
                            local texture = Assets.getTexture(icon[1])
                            Draw.draw(texture, text_offset + 30 + (x * 230) + (icon[3] or 0), 50 + (y * 30) + (icon[4] or 0))
                            text_offset = text_offset + (icon[5] or texture:getWidth())
                        end
                    end
                end

                if able then
                    Draw.setColor(item.color or {1, 1, 1, 1})
                else
                    Draw.setColor(COLORS.gray)
                end
                love.graphics.print(item.name, text_offset + 30 + (x * 230), 50 + (y * 30))
                text_offset = text_offset + font:getWidth(item.name)

                if item.icons then
                    if able then
                        Draw.setColor(1, 1, 1)
                    end

                    for _, icon in ipairs(item.icons) do
                        if type(icon) == "string" then
                            icon = {icon, false, 0, 0, nil}
                        end
                        if icon[2] then
                            local texture = Assets.getTexture(icon[1])
                            Draw.draw(texture, text_offset + 30 + (x * 230) + (icon[3] or 0), 50 + (y * 30) + (icon[4] or 0))
                            text_offset = text_offset + (icon[5] or texture:getWidth())
                        end
                    end
                end

                if x == 0 then
                    x = 1
                else
                    x = 0
                    y = y + 1
                end
            end

            -- Print information about currently selected item
            local tp_offset, _ = 0, nil --initialize placeholdder variable so it doenst go in global scope
            local current_item = Game.battle.menu_items[Game.battle:getItemIndex()]
            if current_item.description then
                Draw.setColor(COLORS.gray)
                love.graphics.print(current_item.description, 260 + 240, 50)
                Draw.setColor(1, 1, 1, 1)
                _, tp_offset = current_item.description:gsub('\n', '\n')
                tp_offset = tp_offset + 1
            end
---------------------------------------------------------------------------------  --Replace the current_item.tp function with this and what not.
            if not Game.battle.party[Game.battle.current_selecting].chara:isBloodPriceUser() then
                if current_item.tp and current_item.tp ~= 0 then
                    Draw.setColor(PALETTE["tension_desc"])
                    love.graphics.print(math.floor((current_item.tp / Game:getMaxTension()) * 100) .. "% "..Game:getConfig("tpName"), 260 + 240, 50 + (tp_offset * 32))
                    Game:setTensionPreview(current_item.tp)
                else
                    Game:setTensionPreview(0)
                end

            else
                if current_item.bp and current_item.bp ~= 0 then
                    --print("henlo")
                    Draw.setColor(COLORS["red"])
                    if current_item.bp_c == 0 and (current_item.bp_n > 1 or current_item.bp_d > 1) then
                        love.graphics.print(current_item.bp_n .. "/" .. current_item.bp_d .. " MAX HP", 260 + 240, 50 + (tp_offset * 32))
                    else
                        love.graphics.print(current_item.bp .. " HP", 260 + 240, 50 + (tp_offset * 32))
                    end
                    
                    Draw.setColor(1, 1, 1, 1)
                    --_, tp_offset = current_item.description:gsub('\n', '\n')
                    --tp_offset = tp_offset + 1
                end
            end
---------------------------------------------------------------------------------
            Draw.setColor(1, 1, 1, 1)
            if page < max_page then
                Draw.draw(self.arrow_sprite, 470, 120 + (math.sin(Kristal.getTime()*6) * 2))
            end
            if page > 0 then
                Draw.draw(self.arrow_sprite, 470, 70 - (math.sin(Kristal.getTime()*6) * 2), 0, 1, -1)
            end

        elseif Game.battle.state == "ENEMYSELECT" or Game.battle.state == "XACTENEMYSELECT" then
            local enemies = Game.battle.enemies_index

            local page = math.ceil(Game.battle.current_menu_y / 3) - 1
            local max_page = math.ceil(#enemies / 3) - 1
            local page_offset = page * 3

            Draw.setColor(Game.battle.encounter:getSoulColor())
            Draw.draw(self.heart_sprite, 55, 30 + ((Game.battle.current_menu_y - page_offset) * 30))

            local font = Assets.getFont("main")
            love.graphics.setFont(font)

            local draw_mercy = Game:getConfig("mercyBar")
            local draw_percents = Game:getConfig("enemyBarPercentages")

            Draw.setColor(1, 1, 1, 1)

            if draw_mercy then
                if Game.battle.state == "ENEMYSELECT" then
                    love.graphics.print("HP", 424, 39, 0, 1, 0.5)
                end
                love.graphics.print("MERCY", 524, 39, 0, 1, 0.5)
            end
            
            for _,enemy in ipairs(Game.battle:getActiveEnemies()) do
                if self.xact_x_pos < font:getWidth(enemy.name) + 142 then
                    self.xact_x_pos = font:getWidth(enemy.name) + 142
                end
            end

            for index = page_offset+1, math.min(page_offset+3, #enemies) do
                local enemy = enemies[index]
                local y_off = (index - page_offset - 1) * 30

                if enemy then
                    local name_colors = enemy:getNameColors()
                    if type(name_colors) ~= "table" then
                        name_colors = {name_colors}
                    end

                    if #name_colors <= 1 then
                        Draw.setColor(name_colors[1] or enemy.selectable and {1, 1, 1} or {0.5, 0.5, 0.5})
                        love.graphics.print(enemy.name, 80, 50 + y_off)
                    else
                        -- Draw the enemy name to a canvas first
                        local canvas = Draw.pushCanvas(font:getWidth(enemy.name), font:getHeight())
                        Draw.setColor(1, 1, 1)
                        love.graphics.print(enemy.name)
                        Draw.popCanvas()

                        -- Define our gradient
                        local color_canvas = Draw.pushCanvas(#name_colors, 1)
                        for i = 1, #name_colors do
                            -- Draw a pixel for the color
                            Draw.setColor(name_colors[i])
                            love.graphics.rectangle("fill", i-1, 0, 1, 1)
                        end
                        Draw.popCanvas()

                        -- Reset the color
                        Draw.setColor(1, 1, 1)

                        -- Use the dynamic gradient shader for the spare/tired colors
                        local shader = Kristal.Shaders["DynGradient"]
                        love.graphics.setShader(shader)
                        -- Send the gradient colors
                        shader:send("colors", color_canvas)
                        shader:send("colorSize", {#name_colors, 1})
                        -- Draw the canvas from before to apply the gradient over it
                        Draw.draw(canvas, 80, 50 + y_off)
                        -- Disable the shader
                        love.graphics.setShader()
                    end

                    Draw.setColor(1, 1, 1)

                    local spare_icon = false
                    local tired_icon = false
                    if enemy.tired and enemy:canSpare() then
                        Draw.draw(self.sparestar, 80 + font:getWidth(enemy.name) + 20, 60 + y_off)
                        Draw.draw(self.tiredmark, 80 + font:getWidth(enemy.name) + 40, 60 + y_off)
                        spare_icon = true
                        tired_icon = true
                    elseif enemy.tired then
                        Draw.draw(self.tiredmark, 80 + font:getWidth(enemy.name) + 40, 60 + y_off)
                        tired_icon = true
                    elseif enemy.mercy >= 100 then
                        Draw.draw(self.sparestar, 80 + font:getWidth(enemy.name) + 20, 60 + y_off)
                        spare_icon = true
                    end

                    for i = 1, #enemy.icons do
                        if enemy.icons[i] then
                            if (spare_icon and (i == 1)) or (tired_icon and (i == 2)) then
                                -- Skip the custom icons if we're already drawing spare/tired ones
                            else
                                Draw.setColor(1, 1, 1, 1)
                                Draw.draw(enemy.icons[i], 80 + font:getWidth(enemy.name) + (i * 20), 60 + y_off)
                            end
                        end
                    end

                    if Game.battle.state == "XACTENEMYSELECT" then
                        Draw.setColor(Game.battle.party[Game.battle.current_selecting].chara:getXActColor())
                        if Game.battle.selected_xaction.id == 0 then
                            love.graphics.print(enemy:getXAction(Game.battle.party[Game.battle.current_selecting]), self.xact_x_pos, 50 + y_off)
                        else
                            love.graphics.print(Game.battle.selected_xaction.name, self.xact_x_pos, 50 + y_off)
                        end
                    end

                    if Game.battle.state == "ENEMYSELECT" then
                        local namewidth = font:getWidth(enemy.name)

                        Draw.setColor(128/255, 128/255, 128/255, 1)

                        if ((80 + namewidth + 60 + (font:getWidth(enemy.comment) / 2)) < 415) then
                            love.graphics.print(enemy.comment, 80 + namewidth + 60, 50 + y_off)
                        else
                            love.graphics.print(enemy.comment, 80 + namewidth + 60, 50 + y_off, 0, 0.5, 1)
                        end


                        local hp_percent = enemy.health / enemy.max_health

                        local hp_x = draw_mercy and 420 or 510

                        if enemy.selectable then
                            -- Draw the enemy's HP
                            Draw.setColor(PALETTE["action_health_bg"])
                            love.graphics.rectangle("fill", hp_x, 55 + y_off, 81, 16)

                            Draw.setColor(PALETTE["action_health"])
                            love.graphics.rectangle("fill", hp_x, 55 + y_off, math.ceil(hp_percent * 81), 16)

                            if draw_percents then
                                Draw.setColor(PALETTE["action_health_text"])
                                love.graphics.print(math.ceil(hp_percent * 100) .. "%", hp_x + 4, 55 + y_off, 0, 1, 0.5)
                            end
                        end
                    end

                    if draw_mercy then
                        -- Draw the enemy's MERCY
                        if enemy.selectable then
                            Draw.setColor(PALETTE["battle_mercy_bg"])
                        else
                            Draw.setColor(127/255, 127/255, 127/255, 1)
                        end
                        love.graphics.rectangle("fill", 520, 55 + y_off, 81, 16)

                        if enemy.disable_mercy then
                            Draw.setColor(PALETTE["battle_mercy_text"])
                            love.graphics.setLineWidth(2)
                            love.graphics.line(520, 56 + y_off, 520 + 81, 56 + y_off + 16 - 1)
                            love.graphics.line(520, 56 + y_off + 16 - 1, 520 + 81, 56 + y_off)
                        else
                            Draw.setColor(1, 1, 0, 1)
                            love.graphics.rectangle("fill", 520, 55 + y_off, ((enemy.mercy / 100) * 81), 16)

                            if draw_percents and enemy.selectable then
                                Draw.setColor(PALETTE["battle_mercy_text"])
                                love.graphics.print(math.ceil(enemy.mercy) .. "%", 524, 55 + y_off, 0, 1, 0.5)
                            end
                        end
                    end
                end
            end

            Draw.setColor(1, 1, 1, 1)
            local arrow_down = page_offset + 3
            while true do
                arrow_down = arrow_down + 1
                if arrow_down > #enemies then
                    arrow_down = false
                    break
                elseif enemies[arrow_down] then
                    arrow_down = true
                    break
                end
            end
            local arrow_up = page_offset + 1
            while true do
                arrow_up = arrow_up - 1
                if arrow_up < 1 then
                    arrow_up = false
                    break
                elseif enemies[arrow_up] then
                    arrow_up = true
                    break
                end
            end
            if arrow_down then
                Draw.draw(self.arrow_sprite, 20, 120 + (math.sin(Kristal.getTime()*6) * 2))
            end
            if arrow_up then
                Draw.draw(self.arrow_sprite, 20, 70 - (math.sin(Kristal.getTime()*6) * 2), 0, 1, -1)
            end
        elseif Game.battle.state == "PARTYSELECT" then
            local page = math.ceil(Game.battle.current_menu_y / 3) - 1
            local max_page = math.ceil(#Game.battle.party / 3) - 1
            local page_offset = page * 3

            Draw.setColor(Game.battle.encounter:getSoulColor())
            Draw.draw(self.heart_sprite, 55, 30 + ((Game.battle.current_menu_y - page_offset) * 30))

            local font = Assets.getFont("main")
            love.graphics.setFont(font)

            for index = page_offset+1, math.min(page_offset+3, #Game.battle.party) do
                Draw.setColor(1, 1, 1, 1)
                love.graphics.print(Game.battle.party[index].chara:getName(), 80, 50 + ((index - page_offset - 1) * 30))

                Draw.setColor(PALETTE["action_health_bg"])
                love.graphics.rectangle("fill", 400, 55 + ((index - page_offset - 1) * 30), 101, 16)

                local percentage = Game.battle.party[index].chara:getHealth() / Game.battle.party[index].chara:getStat("health")
                Draw.setColor(PALETTE["action_health"])
                love.graphics.rectangle("fill", 400, 55 + ((index - page_offset - 1) * 30), math.ceil(percentage * 101), 16)
            end

            Draw.setColor(1, 1, 1, 1)
            if page < max_page then
                Draw.draw(self.arrow_sprite, 20, 120 + (math.sin(Kristal.getTime()*6) * 2))
            end
            if page > 0 then
                Draw.draw(self.arrow_sprite, 20, 70 - (math.sin(Kristal.getTime()*6) * 2), 0, 1, -1)
            end
        end
        if Game.battle.state == "ATTACKING" or self.attacking then
            Draw.setColor(PALETTE["battle_attack_lines"])
            if not Game:getConfig("oldUIPositions") then
                -- Chapter 2 attack lines
                love.graphics.rectangle("fill", 79, 78, 224, 2)
                love.graphics.rectangle("fill", 79, 116, 224, 2)
            else
                -- Chapter 1 attack lines
                local has_index = {}
                for _,box in ipairs(self.attack_boxes) do
                    has_index[box.index] = true
                end
                love.graphics.rectangle("fill", has_index[2] and 77 or 2, 78, has_index[2] and 226 or 301, 3)
                love.graphics.rectangle("fill", has_index[3] and 77 or 2, 116, has_index[3] and 226 or 301, 3)
            end
        end
    end)

    Utils.hook(Battle, "canSelectMenuItem", function(orig, self, menu_item)
            
        orig(self, menu_item)

        local str = menu_item.name
        if self.party[self.current_selecting].chara:isBloodPriceUser() and Game.battle.state_reason == "SPELL" then
            if menu_item.action == "SPELL" and (not string.match(str, "-Action") and menu_item.bp == 0) or (menu_item.bp >= self.party[self.current_selecting].chara:getHealth()) then
                return false
            end
        end
   
        return true

    end)

    Utils.hook(Battle, "addMenuItem", function(orig, self, tbl)

        tbl = {
            ["name"] = tbl.name or "",
            ["tp"] = tbl.tp or 0,
            ["bp"] = tbl.bp or 0,
--------------------------------------------------            
            ["bp_c"] = tbl.bp_c or 0,
            ["bp_n"] = tbl.bp_n or 0,
            ["bp_d"] = tbl.bp_d or 0,
--------------------------------------------------
            ["unusable"] = tbl.unusable or false,
            ["description"] = tbl.description or "",
            ["party"] = tbl.party or {},
            ["color"] = tbl.color or {1, 1, 1, 1},
            ["data"] = tbl.data or nil,
            ["callback"] = tbl.callback or function() end,
            ["highlight"] = tbl.highlight or nil,
            ["icons"] = tbl.icons or nil
        }
        table.insert(self.menu_items, tbl)
        return tbl
    end)

    Utils.hook(EnemyBattler, "onTurnEnd", function(orig, self, ...)
        orig(self, ...)
    
        for _,battler in ipairs(Game.party) do
            if battler:isBloodPriceUser() then
                battler:setFlag("current_hp", battler:getHealth() or nil)
            end
        end

    end)

    Utils.hook(Spell, "init", function(orig, self, ...)
    
        orig(self, ...)

        self.use_blood_price = false

        self.blood_price_cost = 0    --Flat HP cost. THIS TAKES PREDCENDECE, SO BE SURE TO SET IT TO 0 (default) IF YOU USE THE MAX HP TABLE!

        self.blood_price_max_hp = { --Use instead this to make blood price based on max hp; 
        ["numerator"] = 1,          --Should default to 1
        ["denominator"] = 1         --Should default to 1
        }

        self.blood_price_perma_cost = false   --Whether to subract from your HP STAT!

    end)

    Utils.hook(Spell, "useBloodPrice", function(orig, self)
        return self.use_blood_price
    end)

    Utils.hook(Spell, "getBloodPrice", function(orig, self, chara)
    
        if self:getBPFlatCost() == 0 and (self:getBPNumerator() > 1 or self:getBPDenominator() > 1) then
                
            return Utils.round((self:getBPNumerator() * chara:getStat("health")) / self:getBPDenominator())
    
        else
            return self:getBPFlatCost()
        end
        
    end)

    Utils.hook(Spell, "getBPNumerator", function(orig, self)
        return self.blood_price_max_hp.numerator
    end)

    Utils.hook(Spell, "getBPDenominator", function(orig, self)
        return self.blood_price_max_hp.denominator
    end)

    Utils.hook(Spell, "getBPFlatCost", function(orig, self)
        return self.blood_price_cost
    end)

    Utils.hook(Spell, "useUpHPStat", function(orig, self)
    
        return self.blood_price_perma_cost

    end)

    Utils.hook(PartyMember, "init", function(orig, self, ...)
    
        orig(self, ...)

        self.blood_price_user = false

    end)

    Utils.hook(PartyMember, "isBloodPriceUser", function(orig, self)
        return self.blood_price_user
    end)

end

local BloodMagicButton, super = Class(ActionButton)

function BloodMagicButton:init()
    super.init(self, "bloodmagic")
end

function lib:getActionButtons(battler, buttons)
    if battler.chara:isBloodPriceUser() then
        Utils.removeFromTable(buttons, "spare")
        Utils.removeFromTable(buttons, "item")
        Utils.removeFromTable(buttons, "defend")
        Utils.removeFromTable(buttons, "magic")
        table.insert(buttons, BloodMagicButton())
        table.insert(buttons, "item")
        table.insert(buttons, "spare")
        table.insert(buttons, "defend")
    end
    return buttons
end

function lib:onActionSelect(battler, button)

    if button.type == "bloodmagic" then
        Game.battle:clearMenuItems()
        
        -- First, register X-Actions as menu items.

        if Game.battle.encounter.default_xactions and battler.chara:hasXAct() then
            local spell = {
                ["name"] = Game.battle.enemies[1]:getXAction(battler),
                ["target"] = "xact",
                ["id"] = 0,
                ["default"] = true,
                ["party"] = {},
                ["tp"] = 0,
                ["bp"] = 0
            }

            Game.battle:addMenuItem({
                ["name"] = battler.chara:getXActName() or "X-Action",
                ["tp"] = 0,
                ["bp"] = 0,
                ["color"] = {battler.chara:getXActColor()},
                ["data"] = spell,
                ["callback"] = function(menu_item)
                    Game.battle.selected_xaction = spell
                    Game.battle:setState("XACTENEMYSELECT", "SPELL")
                end
            })
        end

        for id, action in ipairs(Game.battle.xactions) do
            if action.party == battler.chara.id then
                local spell = {
                    ["name"] = action.name,
                    ["target"] = "xact",
                    ["id"] = id,
                    ["default"] = false,
                    ["party"] = {},
                    ["tp"] = 0,
                    ["bp"] = 0
                }

                Game.battle:addMenuItem({
                    ["name"] = action.name,
                    --["tp"] = 0,
                    ["bp"] = 0,
                    ["description"] = action.description,
                    ["color"] = action.color or {1, 1, 1, 1},
                    ["data"] = spell,
                    ["callback"] = function(menu_item)
                        Game.battle.selected_xaction = spell
                        Game.battle:setState("XACTENEMYSELECT", "SPELL")
                    end
                })
            end
        end

        -- Now, register SPELLs as menu items.
        for _,spell in ipairs(battler.chara:getSpells()) do
            local color = spell.color or {1, 1, 1, 1}
            if spell:hasTag("spare_tired") then
                local has_tired = false
                for _,enemy in ipairs(Game.battle:getActiveEnemies()) do
                    if enemy.tired then
                        has_tired = true
                        break
                    end
                end
                if has_tired then
                    color = {0, 178/255, 1, 1}
                end
            end
            Game.battle:addMenuItem({
                ["name"] = spell:getName(),
                ---["tp"] = spell:getTPCost(battler.chara),
                ["bp"] = spell:getBloodPrice(battler.chara),
                ["bp_c"] = spell:getBPFlatCost(),
                ["bp_n"] = spell:getBPNumerator(),
                ["bp_d"] = spell:getBPDenominator(),
                ["unusable"] = not spell:isUsable(battler.chara),
                ["description"] = spell:getBattleDescription(),
                ["party"] = spell.party,
                ["color"] = color,
                ["data"] = spell,
                ["callback"] = function(menu_item)
                    Game.battle.selected_spell = menu_item
                    if not spell.target or spell.target == "none" then
                        Game.battle:pushAction("SPELL", nil, menu_item)
                    elseif spell.target == "ally" then
                        Game.battle:setState("PARTYSELECT", "SPELL")
                    elseif spell.target == "enemy" then
                        Game.battle:setState("ENEMYSELECT", "SPELL")
                    elseif spell.target == "party" then
                        Game.battle:pushAction("SPELL", Game.battle.party, menu_item)
                    elseif spell.target == "enemies" then
                        Game.battle:pushAction("SPELL", Game.battle:getActiveEnemies(), menu_item)
                    end
                end
            })
            
        end
        Game.battle:setState("MENUSELECT", "SPELL")
    end

end

function lib:onBattleActionCommit(action, action_type, battler, target)

    local anim = action.action:lower()
    if action.action == "SPELL" and action.data and battler.chara:isBloodPriceUser() then
            local bp = action.data:getBloodPrice(battler.chara)
            --battler.chara:setFlag("current_hp", battler.chara:getHealth() or nil)
            --local hp = battler.chara:getFlag("current_hp", 0)
            local result = action.data:onSelect(battler, action.target)
            --battler.chara:setFlag("current_hp_stat", battler.chara.stats["health"])
            --print(action.bp)
            if result ~= false then
                if action.tp then
                    --[[
                    if action.tp > 0 then
                        Game:giveTension(action.tp)
                    elseif action.tp < 0 then
                        Game:removeTension(-action.tp)
                    end]] --Should leave this as is for some reason.
                end
                --[[if  battler.chara:getFlag("current_hp", 0) <= bp then
                    --battler.chara:
                    --Game.battle:hurt(hp - 1, true, battler)
                else]]
                if action.data:useUpHPStat() then
                    battler.chara:setFlag("old_hp_stat", battler.chara.stats["health"])
                    battler.chara.stats["health"] = battler.chara.stats["health"] - bp
                    if bp <= battler.chara.stats["health"] then
                        
                    end
                end
                    Game.battle:hurt(bp, true, battler)
                --end
            
            battler:setAnimation("battle/"..anim.."_ready")
            action.icon = anim
        end
    end
end

function lib:onBattleActionUndo(action, action_type, battler, target)

    if action.action == "ITEM" and action.data then
        if action.item_index and action.consumed then
            if action.result_item then
                Game.inventory:setItem(action.item_storage, action.item_index, action.data)
            else
                Game.inventory:addItemTo(action.item_storage, action.item_index, action.data)
            end
        end
        action.data:onBattleDeselect(battler, action.target)
    elseif action.action == "SPELL" and action.data then
        if battler.chara:isBloodPriceUser() then
            local bp = action.data:getBloodPrice(battler.chara)
           --[[ local hp = battler.chara:getFlag("current_hp", 0)
            if hp <= bp then
                battler.chara:heal(hp - 1)
            else]]
            if action.data:useUpHPStat() then
                battler.chara.stats["health"] = battler.chara:getFlag("old_hp_stat", battler.chara.stats["health"])
                battler.chara:heal(battler.chara:getFlag("old_hp_stat", battler.chara.stats["health"]))
            else
                battler.chara:heal(bp)
            end
            
        end
        action.data:onDeselect(battler, action.target)
    end

end

return lib
