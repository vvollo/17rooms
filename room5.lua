-- Доступное пространство имён для объектов - все имена объектов должны начинаться с "room5_" или "podval_" 
-- Все описания можно менять
-- Задача: Это изначально тёмная комната. Игрок может придти как с источником света, так и без него. Задача - найти предмет pyramidekey
room {
	nam = "room5_podval";
	title = "Подвал";
	dsc = function(s)
--	    if (s :has 'light') then
			p "Страшная подвальная комната. Рядом со входом ржавый вентиль с веревкой. "
--		else
--			p "Темно, хоть глаз выколи. Тебе удалось нащупать вентиль на стене и верёвку, свисающую с потолка."
--		end
	end;
	dark_dsc = "Темно, хоть глаз выколи. Тебе удалось нащупать вентиль на стене и верёвку, свисающую с потолка.";
	u_to = 'room4_kladovka';
	before_Listen = "Ничего не слышно.";
	before_Smell = "Ничем не пахнет.";
	obj = { 'room5_verev', 'room5_ventil','room5_podval_decor', 'room5_stena' };
}: attr '~light'

-- Менять нельзя!!!! Это не ваш предмет!!! Вы не знаете как он выглядит, его придумает другой автор!!!
--obj {
--	-"пирамидальный ключ,ключ";
--	nam = "piramidekey";
--	description = "Пирамидальный ключ.";
--}

room {
	nam = "room5_reserve";
	title = "Специальная комната для отработавших обьектов";
}

obj {
   	-"островки|островок|облупившаяся краска,краска|островки краски|островок краски|летающие частицы,частицы|летающая частица,частица|щёлочка|щель|дверной проём|проём",
	nam = 'room5_podval_decor';
}: attr 'scenery'

obj {
   	-"упавшая дверь|дверь",
	nam = 'room5_fall_door';
	description = "Упавшая дверь больше не представляет для тебя интереса.";
}: attr 'scenery'

obj {
	-"небольшая коробка|коробка";
	nam = 'room5_korob';
	obj = { 'piramidekey' };
}: attr 'scenery,container,open'

obj {
   	-"потолок|потолочная ниша|ниша",
	nam = 'room5_nisha';
	description = "Ниша в потолке излучает яркий свет, словно прожектор. Видны летающие частицы пыли.";
}: attr 'scenery'

obj {
   	-"потайная дверь,дверь|кольцо|ручка двери|ручка",
	nam = 'room5_door';
	val_open = 0;
	description =  function(s)
		p("Потайная дверь, ручка выполнена в виде кольца.")
		if (s.val_open == 0) then
		p("Дверь вровень со стеной.")
		elseif (s.val_open == 2) then
		p("Дверь немного раскрылась, оставив небольшую щёлку, размером с волос.")
		elseif (s.val_open == 1) then
		p("Дверь раскрылась на половину ступни.")
		end
	end;
	before_Open = function(s)
	   if (s.val_open == 0) then
	      p("С большим усилием ты потянула за ручку двери и она немного приоткрылась, оставив щёлочку.")
	      s.val_open = 1
	   else
	      p("Как ты ни пыталась тянуть ручку, дверь не поддавалась. Пройти пока невозможно.")
	   end
	   return true
	end;
	before_Pull = function(s)
	   if (s.val_open == 0) then
	      p("С большим усилием ты потянула за ручку двери и она немного приоткрылась, оставив щёлочку.")
	      s.val_open = 1
	   else
	      p("Как ты ни пыталась тянуть ручку, дверь не поддавалась. Пройти пока невозможно.")
	   end
	   return true
	end;
	before_Push = function(s)
	   if (s.val_open == 0) then
	      p("Ты не понимаешь, зачем тебе толкать дверь.")
	   elseif (s.val_open == 1) then
	      p("Попытки приоткрыть дверь обычным способом провалились и ты решила попробовать её захлопнуть. Навалившись все телом тебе удалось её закрыть. Затем она открылась уже немного шире! Может пролезть половина твоей ступни.")
		  s.val_open = 2;
	   else
	      p("Этот трюк больше не работает! Да что сделать с этой проклятой дверью?! Да я её...")
	   end
	   return true
	end;
	before_Attack = function(s)
	   if (s.val_open < 2) then
	      p("Ты не понимаешь, зачем тебе ломать дверь.")
	   else
	      p("Со всей дури ты ударила дверь ногой и она, к твоему удивлению рухнула! Одна из петель совсем прогнила. В проёме показалась небольшая коробка.")
	          mp.score=mp.score+1;
		  move(_'room5_door','room5_reserve')
		  move(_'room5_fall_door','room5_podval')
		  move(_'room5_korob','room5_podval')
	   end
	   return true;
	end;
	
}: attr 'static'

obj {
   	-"стена|стены",
	nam = 'room5_stena';
	description = function(s)
	   if (_'room5_ventil'.is_fixed) then
	      p("Стены больничного белого цвета. Кажется, на одной из стен появилась трещина, явно свежая.")
	   else
	      p("Стены больничного белого цвета. Навевают какие-то мрачные мысли.")
	   end
	end;
}: attr 'scenery'

obj {
   	-"ровная трещина,подозрительная трещина,тонкая трещина,пыльная трещина,трещина|прямоугольник",
	nam = 'room5_tres';
	description = "Трещина на стене тонкая и подозрительно ровная, образует прямоугольник около двух метров в высоту и метра в ширину. Какая же она пыльная!";
	before_Touch = function(s)
		p("Немного потрогав края трещины, ты обнаружила, что это потайная дверь! Чуточку усердия в очистке и дело в шляпе.")
                mp.score=mp.score+1;
		move(s,'room5_reserve')
		move(_'room5_door','room5_podval')
		return true
	end;
	before_Blow = function(s)
		p("Немного подув на трещину, ты обнаружила, что это потайная дверь! Чуточку усердия в очистке и дело в шляпе.")
                mp.score=mp.score+1;
		move(s,'room5_reserve')
		move(_'room5_door','room5_podval')
		return true
	end;
	before_Rub = function(s)
		p("Немного потерев трещину, ты обнаружила, что это потайная дверь! Чуточку усердия в очистке и дело в шляпе.")
                mp.score=mp.score+1;
		move(s,'room5_reserve')
		move(_'room5_door','room5_podval')
		return true
	end;
	before_Attack = function(s)
		p("Немного постучав по трещине, ты обнаружила, что это потайная дверь! Чуточку усердия в очистке и дело в шляпе.")
                mp.score=mp.score+1;
		move(s,'room5_reserve')
		move(_'room5_door','room5_podval')
		return true
	end;
}: attr 'scenery'


obj {
	-"веревка|жгут",
	nam = 'room5_verev';
	blind_desc = "На ощупь эластичный жгут, не очень толстый.";
	light_desc = "Грязная веревка, свисает с какой-то ниши в потолке.";
	is_tied = false;
	description = function(s)
	    if (not mp:thedark()) then
		    p(s.light_desc)
		else
			p(s.blind_desc)
		end
		if (s.is_tied) then
		    p "Веревка привязана к вентилю. Где ей, кажется, самое место."
		end
	end;
	before_Touch = function(s)
		p(s.blind_desc)
		return true
	end;
	before_Take = function(s)
		p "Жгут очень длинный и идёт куда-то наверх. Ты не понимаешь как его взять с собой."
		return true
	end;
	before_Pull = function(s)
		p "Ты потянула жгут на себя и где-то наверху мелькнул свет. К сожалению, жгут оказался слишком тугим и вырвался из рук. Свет погас."
		return true
	end;
	before_Climb = function(s)
		p "В школе у тебя был трояк по физкультуре. Не очень приятное воспоминание, но что поделать. Хотя может в этом что-то есть."
		return true
	end;
	before_Tie = function(s,w)
	    if (s.is_tied) then
			p "Ты уже надежно привязала к вентилю, всё в порядке!"
			return true
	    elseif (w==_'room5_ventil') then
			p "Получилось! Хоть узлы не забыла как вязать."
			mp.score=mp.score+1;
			s.is_tied = true
			return true
		else
			return false
		end;
	end;
}: attr 'scenery,luminous'

obj {
	-"большой вентиль,ржавый вентиль,мерзкий вентиль,вентиль",
	nam = 'room5_ventil';
	numturns = 0;
	is_fixed = false;
	light_desc = "Мерзкий ржавый вентиль с островками облупившейся краски.";
	blind_desc = "На ощупь холодный. Если подналечь, то все крысы разбегутся от жуткого скрипа.";
	description = function(s)
	    if (not mp:thedark()) then
		    p(s.light_desc)
		else
			p(s.blind_desc);
		end
		if (_'room5_verev'.is_tied) then
		   if s.is_fixed or s.numturns > 0 then
		      p "Веревка сильно натянута и она каким-то образом открывает доступ к свету из ниши."
		   else 
		      p "Веревка привязана к вентилю."
		   end
		end
	end;
	before_Touch = function(s)
		p(s.blind_desc)
		return true
	end;
	before_Turn = function(s)
	    if (_'room5_verev'.is_tied == false) then
			p "С очень большим трудом вентиль поддался. Такое ощущение, что им всё-таки иногда пользуются. Но, никакой реакции"
		else
		    if (s.is_fixed == false) then
				if (s.numturns == 0) then
					p "Кажется прошло полгода, прежде чем удалось провернуть вентиль. Откуда-то сверху забрезжил свет..."
					_'room5_podval':attr'light'
					s.numturns = 3;
				elseif (s.numturns < 5) then
					p "Вентиль провернулся намного легче."
					s.numturns = s.numturns+2;
					if (s.numturns >= 5) then
						p "Вентиль начал закручиваться сам по себе! Верёвка максимально натянулась и с потолка раздался грохот. Такое ощущение, что стены содрогнулись! "
						move(_'room5_nisha','room5_podval')
						move(_'room5_tres','room5_podval')
						s.is_fixed = true
                                                mp.score=mp.score+1;
					end
				end
			else
			    p "Вентиль больше не вращается."
			end
		end
		return true
	end;
	each_turn = function(s)
		if (s.is_fixed == false) and (s.numturns > 0) then
			s.numturns = s.numturns-1
			if (s.numturns == 0) then
			   p "Вентиль начал быстро раскручиваться в обратную сторону и свет погас."
			   _'room5_podval':attr'~light'
			end
		end
	end
}: attr 'scenery,luminous'

