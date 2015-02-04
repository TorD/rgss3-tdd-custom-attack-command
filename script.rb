module TDD;end; module TDD::CAC;end; module TDD::CAC::SETTINGS
#############################################################################
#                          CUSTOM ATTACK COMMAND                             
#############################################################################
#
# * Author      Galenmereth / Tor Damian Design (post@tordamian.com)
# * Co-author   Goldstorm (nickagoldstein@gmail.com)
# * Created     2015.02.03
# * Version     1.0.0 (2015.02.03)
# * License     Free for non-commercial and commercial projects. Credit
#               greatly appreciated but not required.
# * Credit      Please credit both authors if you wish to give credit.
# 
#============================================================================
#                            ~ INSTALLATION ~                                 
#============================================================================
#
# Only compatible with RPG Maker VXAce
# ------------------------------------
#
# Copy and paste the script in its entirety into a new slot in the Ace
# script editor, below ▼ Materials and above ▼ Main Process
#
#============================================================================
#                             ~ HOW TO USE ~                                 
#============================================================================
#
# There are two parts to this script:
#
# 1.  It fixes a bug in Ace which makes it so that even if you select a
#     different scope than "One Enemy" for the default Attack skill, it'll
#     still show the enemy select window for selecting "One Enemy".
#     This is rectified, and you can now make the Attack skill any scope,
#     as would be expected.
#
# 2.  OPTIONAL: By setting the ENABLE_CUSTOM_ATTACK_EXTENSION setting to TRUE
#     you enable the custom attack extension, which tells the game to use
#     the first skill in a class's skill list as the Attack command for that
#     class. It will change the name of the command and its functionality.
#     It is the topmost skill in the list, regardless of level, that will be
#     used as the Attack command.
#
#============================================================================
#                              ~ SETTINGS ~                                  
#============================================================================
#
# Enable Custom Attack Extension
# ------------------------------
# Description:  Set this to TRUE to enable the custom attack extension.
#               Remember to put the desired skill for each class's Attack
#               command in the topmost skill slot in that class's skill list.
#
ENABLE_CUSTOM_ATTACK_EXTENSION = FALSE
#
#============================================================================
end

#////////////////////////////////////////////////////////////////////////////
# DO NOT CHANGE THINGS BELOW THIS POINT UNLESS YOU KNOW WHAT YOU'RE DOING  //
#////////////////////////////////////////////////////////////////////////////

class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # * OVERWRITE [Attack] Command
  #--------------------------------------------------------------------------
  def command_attack
    @skill = $data_skills[BattleManager.actor.attack_skill_id]
    execute_skill
  end
  #--------------------------------------------------------------------------
  # * OVERWRITE Skill [OK]
  #--------------------------------------------------------------------------
  def on_skill_ok
    @skill = @skill_window.item
    execute_skill
  end
  #--------------------------------------------------------------------------
  # * NEW Execute Skill
  #--------------------------------------------------------------------------
  def execute_skill
    BattleManager.actor.input.set_skill(@skill.id)
    BattleManager.actor.last_skill.object = @skill
    if !@skill.need_selection?
      @skill_window.hide
      next_command
    elsif @skill.for_opponent?
      select_enemy_selection
    else
      select_actor_selection
    end
  end
end

if TDD::CAC::SETTINGS::ENABLE_CUSTOM_ATTACK_EXTENSION
class Window_ActorCommand < Window_Command
  #--------------------------------------------------------------------------
  # * OVERWRITE Add Attack Command to List
  #--------------------------------------------------------------------------
  def add_attack_command
    add_command($data_skills[@actor.attack_skill_id].name, :attack, @actor.attack_usable?)
  end
end
class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # * NEW Get Skill ID of Normal Attack
  #--------------------------------------------------------------------------
  def attack_skill_id
    $data_classes[class_id].learnings.first.skill_id
  end
  #--------------------------------------------------------------------------
  # * OVERWRITE Setup
  #--------------------------------------------------------------------------
  def setup(actor_id)
    @actor_id = actor_id
    @name = actor.name
    @nickname = actor.nickname
    init_graphics
    @class_id = actor.class_id
    @level = actor.initial_level
    @exp = {}
    @equips = []
    # = New parameter @learnable_learnings
    @learnable_learnings = self.class.learnings.dup
    @learnable_learnings.shift # Remove the first element as that's default attack
    # = 
    init_exp
    init_skills
    init_equips(actor.equips)
    clear_param_plus
    recover_all
  end
  #--------------------------------------------------------------------------
  # * OVERWRITE Initialize Skills
  #--------------------------------------------------------------------------
  def init_skills
    @skills = []
    @learnable_learnings.each do |learning|
      learn_skill(learning.skill_id) if learning.level <= @level
    end
  end
  #--------------------------------------------------------------------------
  # * OVERWRITE Level Up
  #--------------------------------------------------------------------------
  def level_up
    @level += 1
    @learnable_learnings.each do |learning|
      learn_skill(learning.skill_id) if learning.level == @level
    end
  end
end
end