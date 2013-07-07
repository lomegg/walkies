# coding: utf-8
Encoding.default_internal = 'UTF-8'
Encoding.default_external = 'UTF-8'


class Person
  attr_accessor :name, :maxhp, :hp, :xp, :dmg, :weapon, :armor, :items, :disarmed, :drop, :action
  def initialize(name)
    @name=name
    @maxhp=10
    @hp=10
    @xp=0
    @dmg=1
    @weapon=0
    @armor=0
    @items=[]
    @disarmed=false
    @drop=0
  end
  def show_stats
    puts "||===#{@name} vitals===||"
    puts "|| HP = #{@hp}"
    puts "|| XP = #{@xp}"
    if @weapon != 0
      puts "|| Weapon = #{@weapon.name} (DMG 1-#{@dmg})"
    end
    if @armor !=0
      puts "|| Armor = #{@armor.name} (AC #{@armor.value})"
    end
  end       #ВЫВЕСТИ ХП, ЕХР, ОРУЖИЕ И БРОНЮ
  def additem(item)
    @items << item
    puts "++ #{@name} получает #{item.name} ++"
    if item.type == "wpn"
      @weapon=item
      @dmg=item.value
      puts "Теперь #{@name} использует #{item.name} в качестве оружия!"
    elsif item.type == "arm"
      puts "Теперь #{@name} использует #{item.name} в качестве брони!"
      @armor=item
    end
  end    #ДАТЬ ПРЕДМЕТ
  def show_inventory
    @items.each do |item|
      puts item.name
    end
  end
  def disarm
    if @disarmed==false
      print "#{@name} роняет #{@weapon.name}. "  #проверка, что в руке
      @disarmed=true
      @drop=@weapon.name
      # puts "#{@drop} теперь на  полу!"  #смотрим, что в дропе
      @weapon.name="голые руки"
      puts "++ Теперь оружие #{@name} - #{@weapon.name} ++"
      @dmg=1
    else
      @disarmed=false
      @weapon.name=@drop
      @drop=0
      @dmg=@weapon.value
      puts "#{@name} успешно подбирает #{@weapon.name} и вновь готов к битве!"
    end
  end
  def get_action
    print "Ход игрока! Что будем делать?"
    puts ""
    print "Выберите действие: (a) атака (1-#{@dmg} dmg)"
    if @disarmed
      print ", (r) поднять оружие"
    else
      print ", (d) обезоружить противника"
    end
    print ", (i) использовать предмет"
    print " "
    @action=gets.chomp!
  end
end     #creatures

#items
class Item
  attr_accessor :type, :name, :value, :cost, :weight
  def initialize(type, name, value, cost=0, weight=1)
    @type=type
    @name=name
    @value=value
    @cost=cost
    @weight=weight
  end
end

#weapons
shiny_sword=Item.new("wpn","Сияющий меч",10,1000,3)
rusty_sword=Item.new("wpn","Ржавый меч",3,1,3)
unarmed=Item.new("wpn","Кулаки",1)

#armor
rags=Item.new("arm","Лохмотья",1)

#misc
cellphone=Item.new("misc","Мобильник",10+rand(5),500,1)

class Monster < Person
  attr_accessor :name, :maxhp, :hp, :xp, :dmg, :weapon, :armor, :items, :disarmed, :drop
  def initialize(name,weapon=0,armor=0)
    @name=name
    @maxhp=5
    @hp=5
    @xp=10
    @agro=true
    @items=[]
    @weapon=weapon
    @armor=armor
    @disarmed=false
    @drop=0
    @dmg=@weapon.value
    end
end   #при создании инстанса обязательно давать оружие!

#creatures
sceleton= Monster.new("Скелет",rusty_sword,rags)


battle = lambda {|player, monster|

  puts "=========================================================================="
  puts "Битва #{player.name} и #{monster.name}! "
  puts ""
  puts "#{monster.name} одет в #{monster.armor.name}, его оружие - #{monster.weapon.name}!"
  puts ""

  def attack(attacker, defendant, action)
    if action=="a"|| action=="A" || action=="roll"
      puts "#{attacker.name} атакует #{defendant.name}, используя #{attacker.weapon.name}!"
      if action=="roll"
        print "ЧИТ!! Введите ролл: "
        roll=gets.chomp.to_i
        puts "rolled #{roll}"
      else
        roll=rand(20)
      end

      if roll == 20       #Критический удар
        puts "ATK #{roll} vs. AC #{10+defendant.armor.value}, MAX DMG #{attacker.dmg}"
        puts "КРИТИЧЕСКИЙ УДАР! #{attacker.name} наносит мощный удар #{defendant.name}, практически рассекая его надвое! Урон #{attacker.dmg*2} HP"
        defendant.hp -= (attacker.dmg*2)
      elsif roll >(10+defendant.armor.value)  #Если бросок больше 10+АС
        dmroll=rand(attacker.dmg).to_i
        puts "ATK #{roll} vs. AC #{10+defendant.armor.value}, MAX DMG #{attacker.dmg}"
        if dmroll==0
          dmroll=1
        end
        puts "#{attacker.name} бъёт #{defendant.name} с помощью #{attacker.weapon.name}, нанося #{dmroll} единицы урона"
        defendant.hp-=dmroll
      elsif roll > 0     #Промах
        puts "ATK #{roll} vs. AC #{10+defendant.armor.value}, MAX DMG #{attacker.dmg}"
        puts "#{attacker.name} промахивается!"
      else                 #Критический промах
        puts "ATK #{roll} vs. AC #{10+defendant.armor.value}"
        puts "#{attacker.name} пытается нанести сокрушительный удар, но промахивается и теряет свое оружие."
        attacker.disarm
      end

    elsif action=="r" || action=="R"
      attacker.disarm

    elsif action.capitalize=="D"
      puts  "#{attacker.name} пытается обезоружить #{defendant.name}!!!"
      if defendant.disarmed
         puts "#{defendant.name} уже безоружен! "
      else
         if rand(attacker.dmg)>rand(defendant.dmg)
           defendant.disarm
         else
           puts "#{defendant.name} отбивает попытку обезоружить его!"
         end
      end
    else
      puts "Действие не выбрано! #{attacker.name} стоит в замешательстве."

    end
  end     #ФАЗА ХОДА

  #start of the turn
  turn_counter=1
  while player.hp>0 && monster.hp>0 do
    player.show_stats
    puts ""
    monster.show_stats
    puts ""
    puts "=========================================================================="
    print "Ход #{turn_counter}. "
    #puts "#{player.hp>=0}  #{monster.hp>=0}"
    if turn_counter%2==1    #Если ход игрока (нечетный)
        player.get_action
      attack(player, monster, player.action)
    else
      puts "Ход монстра!"
      if monster.disarmed==true
        monster.disarm
      else
        attack(monster, player, "A")
      end
      empty=gets
    end
    puts ""
    turn_counter=turn_counter+1
  end             # ЦИКЛ БИТВЫ
  if player.hp > 0
    puts "HP игрока: #{player.hp} "
    puts "HP монстра: #{monster.hp} "
    puts " ++ Монстр повержен! ++"
    player.xp+=monster.xp
    puts "Получено #{monster.xp} очков опыта! Теперь у #{player.name} #{player.xp} очков опыта!"
  else
    puts " Вы погибли! Игра окончена."
  end                # КТО ПОБЕДИЛ?

}

puts "Ты просыпаешься на холодном каменном полу. Щели меж грубо отёсанных блоков отпечатались на твоем лице. Неприятное ощущение."
puts ""
puts "Ты садишься на полу, открывая глаза. Но увидеть что-либо не удается - все вокруг сокрыто в непроглядной темноте."
puts "Пальцы пытаются нащупать хоть что-нибудь вокруг, в то время как твой разум пытается сделать то же с памятью. Обе попытки бесплодны."
puts "Вопросы, один тревожнее другого, встают перед тобой. Что это за место? Как ты здесь оказался? Кто ты, в конце концов?"
puts ""
puts "На грани паники тебе удается удержаться, сконцентрировавшись на попытках вспомнить своё имя."
print " - Меня зовут... Моё имя - "
#player_name=gets.chomp!.capitalize!
player=Person.new(gets.chomp!)
player.additem(rags)
player.additem(unarmed)

puts ""
puts "Ну конечно же. #{player.name}. Как вообще можно было забыть своё имя?"
puts "Ты облегченно вздыхаешь. По крайней мере, одной проблемой меньше."
puts "Немного переведя дух, ты вспоминаешь про мобильник и извлекаешь его из кармана."
puts ""

player.additem(cellphone)


puts "Экран реагирует на нажатие вспышкой ядерной бомбы. Ты жмуришься, пока пальцы привычно лезут в настройки яркости."
puts "Отрегулировав яркость, ты замечаешь, что батарея почти села: осталось всего #{cellphone.value}% заряда."

puts "You starting to panic a little."
puts ""
puts ""
puts ""

puts "Переведя дух, ты ощущаешь легкое жжение на внутренней стороне левого предплечья."
puts ""

puts "Обшарив еще раз карманы, ты осматриваешь свой нехитрый скарб:"


system('cls')    #не работает сучка





#бой со скелетом здесь





player.additem(shiny_sword)

battle.call(player,sceleton)
puts ""
puts ""
puts ""

#player.show_stats
#player.show_inventory

#comment

