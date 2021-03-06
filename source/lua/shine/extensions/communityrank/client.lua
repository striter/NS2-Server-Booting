local Plugin = ...

function Plugin:Initialise()
	Shine.Hook.SetupClassHook( "GUIScoreboard", "UpdateTeam", "OnGUIScoreboardUpdateTeam", "PassivePost" )
    Plugin._GUIScoreboardUpdateTeam = Shine.ReplaceClassMethod("GUIScoreboard", "UpdateTeam", self.GUIScoreboardUpdateTeam);
    return true
end
  
Plugin.GUIScoreboardUpdateTeam = function(scoreboard, updateTeam)
    Plugin._GUIScoreboardUpdateTeam(scoreboard, updateTeam)
        local playerList = updateTeam["PlayerList"]
        local teamScores = updateTeam["GetScores"]()
        local currentPlayerIndex = 1
        
        local sumPlayerSkill = 0
        local sumPlayers = 0
        for _, player in ipairs(playerList) do
            if not scoreboard.hoverMenu.background:GetIsVisible() and not MainMenu_GetIsOpened() then
                
                local playerRecord = teamScores[currentPlayerIndex]
                if playerRecord == nil then return end
                local clientIndex = playerRecord.ClientIndex
                if GetSteamIdForClientIndex(clientIndex) ~= 0 then
                    sumPlayerSkill = sumPlayerSkill + playerRecord.Skill
                    sumPlayers = sumPlayers + 1
                end

                if MouseTracker_GetIsVisible() then
                    local mouseX, mouseY = Client.GetCursorPosScreen()
                    local skillIcon = player.SkillIcon
                    if skillIcon:GetIsVisible() and GUIItemContainsPoint(skillIcon, mouseX, mouseY) then

                        for _, pie in ientitylist(Shared.GetEntitiesWithClassname("PlayerInfoEntity")) do
                            if pie.clientId == clientIndex then
                                
                                local description = skillIcon.tooltipText
                                description = description .. string.format("\n 段位分: %i\n NS2段位分: %i\n 社区校正分: %i\n\n NS2ID: %i", pie.playerSkill,pie.hiveskill,pie.communityRank,pie.steamId)
                                scoreboard.badgeNameTooltip:SetText(description)
                                break
                            end
                        end
                    end
                end
            end
            
            currentPlayerIndex = currentPlayerIndex + 1
        end

        local teamNameGUIItem = updateTeam["GUIs"]["TeamName"]
        local teamSkillGUIItem = updateTeam["GUIs"]["TeamSkill"]
        if updateTeam.TeamNumber >= 1 and updateTeam.TeamNumber <= 2 then --and numPlayers > 0 then -- Display for only aliens or marines

            local avgSkill = sumPlayerSkill / math.max(1,sumPlayers)
            
            local teamHeaderText = teamNameGUIItem:GetText()
            teamHeaderText = string.sub(teamHeaderText, 1, string.len(teamHeaderText) - 1) -- Original header
    
            teamHeaderText = teamHeaderText .. string.format(", %i 均分)", avgSkill) -- Skill Average
            --
    
            teamNameGUIItem:SetText( teamHeaderText )
            
            teamSkillGUIItem:SetPosition(Vector(teamNameGUIItem:GetTextWidth(teamNameGUIItem:GetText()) + 20, 5, 0) * GUIScoreboard.kScalingFactor)
        end
end