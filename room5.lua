room {
	nam = "room5_podval";
	title = "Подвал";
	dsc = "Страшная подвальная комната. Здесь расположен водопровод дома.";
	dark_dsc = "Темно, хоть глаз выколи.";
	u_to = 'room4_kladovka';
	out_to = 'room4_kladovka';
	before_Listen = "Ничего не слышно.";
	before_Smell = "Ничем не пахнет.";
	before_Tie = function(s, w, wh)
		if wh == _'room5_verev' and w ~= _'room5_ventil' then
			mp:xaction('PutOn', w, wh);
		else
			return false;
		end
	end;
	obj = { 'room5_ventil', 'room5_verev', 'room5_podval_decor', 'room5_stena', 'room5_fotoelem', 'room5_wire' };
}: attr '~light'

obj {
   	-"островки|островок|облупившаяся краска,краска|островки краски|островок краски|летающие частицы,частицы|летающая частица,частица|щёлочка|щель|дверной проём|проём|труба|трубы|водопровод",
	nam = 'room5_podval_decor';
}: attr 'scenery'

obj {
   	-"упавшая дверь|дверь",
	nam = 'room5_fall_door';
	description = "Упавшая дверь больше не представляет для тебя интереса.";
	dsc = "На полу валяется дверь.";
	before_Take = function(s)
		p "Ты не хочешь таскать с собой дверь."
		return true
	end;
}: attr 'static'

obj {
	-"небольшая коробка|коробка";
	nam = 'room5_korob';
	dsc = function(s)
		pr 'В проёме видна небольшая коробка. ';
		mp:content(s);
	end;
	before_Take = function(s)
		p "Тебе не нужна коробка."
		return true
	end;
	obj = { 'piramidekey' };
}: attr 'static,container,open'

obj {
   	-"потолок|потолочная ниша|ниша",
	nam = 'room5_nisha';
	description = "Ниша в потолке излучает яркий свет, словно прожектор. Видны летающие частицы пыли.";
	dsc = "Свет проникает в комнату через нишу в потолке.";
}: attr 'static'

obj {
   	-"потайная дверь,дверь|кольцо|ручка двери|ручка",
	nam = 'room5_door';
	val_open = 0;
	description =  function(s)
		p("Потайная дверь, ручка выполнена в виде кольца.")
		if (s.val_open == 0) then
		p("Дверь вровень со стеной.")
		elseif (s.val_open == 1) then
		p("Дверь немного раскрылась, оставив небольшую щёлку, размером с волос.")
		elseif (s.val_open == 2) then
		p("Дверь раскрылась на половину ступни.")
		end
	end;
	["before_Open,Pull"] = function(s)
	   if (s.val_open == 0) then
	      p("С большим усилием ты потянула за ручку двери и она немного приоткрылась, оставив щёлочку.")
	      s.val_open = 1
	   else
	      p("Как ты ни пыталась тянуть ручку, дверь не поддавалась. Пройти пока невозможно.")
	   end
	   return true
	end;
	["before_Close,Push"] = function(s)
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
		  remove(s)
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
	dsc = "Стена пошла трещиной.";
	before_Touch = function(s)
		s:tearApart("потрогав края трещины")
	end;
	before_Blow = function(s)
		s:tearApart("подув на трещину")
	end;
	before_Rub = function(s)
		s:tearApart("потерев трещину")
	end;
	before_Attack = function(s)
		s:tearApart("постучав по трещине")
	end;
	tearApart = function(s, t)
		p("Немного " .. t .. ", ты обнаружила, что это потайная дверь! Чуточку усердия в очистке и дело в шляпе.")
                mp.score=mp.score+1;
		remove(s)
		move(_'room5_door','room5_podval')
		return true
	end;
}: attr 'static'


obj {
	-"веревка|жгут",
	nam = 'room5_verev';
	dsc =  function(s)
		if (s.is_tied) then
		    return "К нему привязана веревка."
		else
		    return "Откуда-то сверху свисает веревка.";
		end
	end;
	blind_desc = "На ощупь эластичный жгут, не очень толстый.";
	light_desc = "Грязная веревка, свисает с какой-то ниши в потолке.";
	is_tied = false;
	is_held = 0;
	description = function(s)
	    if (not mp:thedark()) then
		    p(s.light_desc)
		else
			p(s.blind_desc)
		end
		if (s.is_tied) then
		    p "Веревка привязана к вентилю. Где ей, кажется, самое место."
		end
		if (_'room5_ventil'.numturns > 0) then
			p "Веревка натянута.";
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
		if (s.is_held > 0) then
			p "Ты и так стараешься как можешь.";
		elseif (_'room5_ventil'.numturns > 0) then
			p "Веревка уже натянута благодаря вентилю.";
		else
			s.is_held = 2;
			p "Ты потянула жгут на себя и где-то наверху мелькнул свет. Его лучи упали прямо на фотоэлемент, и лампочка на нем засветилась желтым."
		end
		return true
	end;
	["before_Climb,Enter"] = function(s)
		p "В школе у тебя был трояк по физкультуре. Не очень приятное воспоминание, но что поделать. Хотя может в этом что-то есть."
		return true
	end;
	before_Tie = function(s,w)
		if w == _'room5_ventil' then
			if (s.is_tied) then
				p "Ты уже надежно привязала к вентилю, всё в порядке!"
				return true
			else
				p "Получилось! Хоть узлы не забыла как вязать."
				mp.score=mp.score+1;
				s.is_tied = true
				return true
			end
		else
			return false
		end;
	end;
	before_Receive = function(s,w)
		p "Для успеха этой затеи нужно повесить предмет, который тяжелее тебя. Лучше придумать что-нибудь другое."
	end;
	each_turn = function(s)
		if (s.is_held > 0) then
			s.is_held = s.is_held - 1;
			if (s.is_held == 0) then
				p "Жгут оказался слишком тугим и вырвался из рук. Свет погас. Лампочка на фотоэлементе снова стала красной.";
			end
		end
	end;
}: attr 'static,supporter'

obj {
	-"большой вентиль,ржавый вентиль,мерзкий вентиль,вентиль",
	nam = 'room5_ventil';
	dsc = "Прямо рядом со входом труба со ржавым вентилем на ней.";
	numturns = 0;
	is_fixed = false;
	tried_turn = false;
	light_desc = "Мерзкий ржавый вентиль с островками облупившейся краски. В его тени притаилась миниатюрная солнечная батарея.";
	blind_desc = "На ощупь холодный. Если подналечь, то все крысы разбегутся от жуткого скрипа.";
	description = function(s)
	    if (not mp:thedark()) then
		    p(s.light_desc)
		else
			p(s.blind_desc);
		end
		if (_'room5_verev'.is_tied) then
		   p "К вентилю привязана веревка."
		   if s.is_fixed or s.numturns > 0 then
			p "Она сильно натянута и каким-то образом открывает доступ к свету из ниши."
		   end
		end
	end;
	before_Touch = function(s)
		p(s.blind_desc)
		return true
	end;
	["before_Turn,Open,Push,Pull"] = function(s)
		if  (_'room5_verev'.is_held > 0) then
			p "Ты не можешь вращать вентиль, пока твои руки заняты веревкой.";
			return true;
		end
		s.tried_turn = true;
		if (not _'room5_verev'.is_tied) then
			p "С очень большим трудом вентиль поддался. Внезапно лампочка на фотоэлементе замигала красным, раздалось гудение, и вентиль самопроизвольно вернулся в исходное положение. Какого?!"
		else
		    if (s.is_fixed == false) then
				if (s.numturns == 0) then
					p "Кажется прошло полгода, прежде чем удалось провернуть вентиль. Откуда-то сверху забрезжил солнечный свет. Его лучи упали прямо на фотоэлемент..."
					_'room5_podval':attr'light'
					s.numturns = 3;
				elseif (s.numturns < 5) then
					s.numturns = s.numturns+2;
					if (s.numturns >= 5) then
						p "Вентиль начал закручиваться сам по себе! Верёвка максимально натянулась, и с потолка раздался грохот. Из трубы внезапно хлынул мощный поток воды и ударил прямо в стену! Правда, он так же быстро иссяк. ^Ну, спасибо, что хоть не в меня!"
						move(_'room5_nisha','room5_podval')
						move(_'room5_tres','room5_podval')
						s.is_fixed = true
                                                mp.score=mp.score+1;
					else
						p "Вентиль провернулся намного легче."
					end
				end
			else
			    p "Вентиль больше не вращается."
			end
		end
		return true
	end;
	before_Tie = function(s,w)
		if w == _'room5_verev' then
			mp:xaction('Tie', w, s)
		else
			return false
		end
	end;
	before_Close = function(s)
		if (s.numturns == 0) then
			p "Он и так закрыт."
		elseif not s.is_fixed then
			p "Он сам того и гляди закрутится."
		else
			p "После того, как ты его с таким трудом открутила? Нет уж."
		end
	end;
	each_turn = function(s)
		if (s.is_fixed == false) and (s.numturns > 0) then
			s.numturns = s.numturns-1
			if (s.numturns == 0) then
			   p "Вентиль начал быстро раскручиваться в обратную сторону и свет погас."
			   _'room5_podval':attr'~light'
			end
		end
	end;
}: attr 'static'

obj {
   	-"солнечная батарея,батарея,батарейка|фотоэлемент,фото-элемент,элемент,прибор|лампочка";
	nam = 'room5_fotoelem';
	description = function(s)
		p "Маленькая солнечная батарея (или фотоэлемент?) с лампочкой-индикатором. От батареи прямо к вентилю уходят проводки. "
		if _'room5_ventil'.is_fixed then
			p "Сейчас лампочка горит зеленым."
		elseif (_'room5_ventil'.numturns == 0) and (_'room5_verev'.is_held == 0) then
			p "Сейчас лампочка горит красным. Неудивительно, ведь на фотоэлемент не падает солнечный свет."
		else
			p "Сейчас лампочка горит желтым. Видимо, фотоэлемент освещен недостаточно."
		end
	end;
}: attr 'scenery'

obj {
   	-"проводки,провода";
	nam = 'room5_wire';
	description = function(s)
		if (not _'room5_ventil'.tried_turn) then
			p "Непонятно, зачем нужны эти проводки."
		else
			p "Ага, похоже, по этим проводам на вентиль поступает информация с фотоэлемента. Чем хуже он освещен, тем быстрее вентиль закручивается в обратную сторону!"
		end
	end;
	["before_Attack,Tear,Cut,Push,Pull"] = function(s)
		return "Если повредишь провода, вся система может заблокироваться. Лучше не рисковать.";
	end;
}: attr 'scenery'
