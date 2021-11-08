global { song = 0 }

room {
   nam = "room4_kladovka";
   title = "Кладовка";
   transported = false,
   dsc = function(s)
	  local v = ""
	  if from() ^ "room4_ostrov" and s:once() then
		--"увидеть"
		--"оказаться"
		v = "{#Me/им} {#word/увидеть,#me,прш} своё отражение, стоящее в кладовке. Затем мир покачнулся, и {#me/им} снова {#word/оказаться,#me,прш} в тесной комнате.^^"
	  end
	  return v .. "Тесная неинтересная комната. К западу кухня, на востоке прихожая."
   end;
   onenter = function(s)
	  if not s.transported then
		 s.transported = true
		 move(me(), "room4_ostrov");
		 place("room4_dolphin", "room4_mirror")
		 place("room4_crab", "room4_mirror")
		 place("room4_frog", "room4_mirror")
	  end
   end;
   w_to = "room6_kitchen";
   e_to = function(s)
		if _'room3_hall'.west == 0 then
		  p 'Ты толкнула дверь и оказалась в прихожей. Оказывается, здесь есть проход! Теперь ходить между помещениями будет куда удобней!';
		  _'room3_hall'.west = 1;
                end;
		return 'room3_hall';
   end;
   d_to = function(s)
	  if _"room4_hatch":has "open" then
		 return "room5_podval"
	  elseif _"room4_hatch":has "locked" then
		 p "Люк заперт."
	  else
		 p "Люк закрыт."
	  end
   end;
   before_Listen = "Ничего не слышно.";
   before_Smell = "Ничем не пахнет.";
   obj = {
	  nam = "room4_bonekey",
	  obj {
			-"зеркало|стекло";
		 nam = "room4_mirror";
		 seen = false,
		 dsc = function(s)
			if here() ^ "room4_kladovka" then
			   return "На стене висит старинное зеркало.";
			else
			   return "Прямо в воздухе висит старинное зеркало.";
			end
		 end;
		 description = function(s)
			if here() ^ "room4_kladovka" then
			   return [[Большое зеркало в старинной бронзовой раме, представляющей собой осьминога, растопырившего щупальца.]];
			else
			   return [[Большое зеркало в бронзовой раме по краю которой располагаются чеканные фигурки: змеи, краба и дельфина.]];
			end
		 end;
		 before_Search = function(s)
			if not s.seen then
			   if where("room4_sapfir") ^ "room4_dolphin" and where("room4_rybin") ^ "room4_crab" and where("room4_izymryd") ^ "room4_frog" then
				  s.seen = true
				  island_drop_items()
				  move(me(), "room4_kladovka")
				  disable("room4_dolphin")
				  disable("room4_crab")
				  disable("room4_frog")
				  mp.score=mp.score+1
			   else
				  --"посмотреть"
				  return "Твоё отражение в зеркале выглядит как обычно. Ничего странного не происходит."
			   end
			else
			   return "{#Me/вн} закрутило, завертело и втянуло прямо в зеркало. {#Me/им} снова {#word/оказаться,#me,прш} в кладовке. Ну и чудеса..."
			end
		 end;
		 ['before_Talk,Ask,AskTo,AskFor,Tell,Answer'] = function(s,w)
			p "Это не то зеркало, с которым стоит разговаривать.";
		 end;
		 before_Take = "Слишком большое и тяжёлое. Невозможно сдвинуть.";
		 before_Smell = "Пахнет морем. Странно, но так и есть.";
		 before_Taste = "Это не съедобно.";
		 before_Touch = "Гладкое и прохладное.";
	  }: attr "static",
	  obj {
			-"стена|стены";
		 description = "Стены покрыты пыльной штукатуркой.";
		 before_Take = "Взять стены? Как?";
		 before_Smell = "Пахнет пылью.";
		 before_Taste = "{#Me/им} не {#word/хотеть,#me,нст} пробовать стены на вкус.";
		 before_Touch = "Шершавые и пыльные стены.";
	  }:attr "scenery",
	  obj {
			-"пол";
		 description = "Каменный пол. Здесь явно не заморачивались с ремонтом.";
		 before_Take = "Взять пол невозможно";
		 before_Smell = "Пахнет пылью.";
		 before_Taste = "{#Me/им} не {#word/хотеть,#me,нст} пробовать камни пола на вкус.";
		 before_Touch = "Прохладный, слегка неровный камень.";
	  }:attr "scenery",
	  obj {
			-"потолок";
		 description = "Потолок покрыт голубой краской.";
		 before_Take = "Взять потолок невозможно";
		 before_Smell = "Не могу допрыгнуть, чтобы понюхать.";
		 before_Taste = "Не дотянусь.";
		 before_Touch = "Увы, не дотянусь.";
	  }:attr "scenery",
   };
}

door {
	  -"люк";
   nam = "room4_hatch";
   when_closed = "В полу виден закрытый люк.";
   when_open = "В полу находится открытый люк.";
   with_key = "bonekey";
   door_to = function(s)
	  if here() ^ "room4_kladovka" then
		 return "room5_podval"
	  else
		 return "room4_kladovka"
	  end
   end;
   found_in = {
	  "room4_kladovka",
   };
   after_Unlock = function(s)
     remove('bonekey');
     mp.score=mp.score+1;
     p "Ты отпираешь люк вниз, избавляясь от костяного ключа.";
   end;
}:attr "openable,lockable,locked,static"

function mermaid_sing()
   local songs = {
	  [[Юные девы в царстве подводном^
	    Живут наслаждаясь, не зная забот.^
		Песни поют о народе свободном.^
		В тёмных глубинах ведут хоровод.]],
	  [[Юные девы в царстве подводном^
	    Жемчугом любят себя украшать,^
		Что перламутром богат бесподобным,^
		И под луной может нежно мерцать.]],
	  [[Юные девы из царства подводного^
	    Мужчин завлекают песней любви.^
		Чарами голоса - дара природного,^
		Страсти огонь разжигают в крови.]],
	  [[Юные девы из царства подводного^
	    Губят ночною порой корабли.^
		Из-за желанья познать, неуёмного,^
		Секреты и тайны верхней земли.]],
   }
	song = song + 1
		if song > #songs then
			song = 1
	end
	return "Раздаётся завораживающая песня русалки:^"..songs[song]
end

-- перенести все брошенные на острове вещи в кладовку
function island_drop_items()
	local oo = {}
	mp:objects(pl:where(), oo)
	for _, o in ipairs(oo) do
		if o:hasnt'static' and o:hasnt'scenery' and o:hasnt'concealed' and not mp:animate(o) and not mp:partof(o) and not o:inside("room4_kladovka") then
			move(o, "room4_kladovka")
		end
	end
end

room {
   nam = "room4_ostrov";
   title = "За зеркалом";
   dsc = function(s)
	  local v = ""
	  if s:once() then
		--"понять"
		v = "Всего лишь мельком {#me/им} {#word/увидеть,#me,прш} своё отражение в старинном зеркале, и {#me/вн} завертело, закружило, ослепило... Проморгавшись, {#me/им} {#word/понять,#me,прш}, что {#word/оказаться,#me,прш} совсем в другом месте.^^"
	  end
	  return v .. "Маленький остров, представляющий собой цветочную поляну, окружённую водой."
   end;
   before_Default = function(s, ev, w, wh)
	if wh == _'room4_gems' then
		p"Камнями лучше распоряжаться по отдельности.";
	else
		return false;
	end;
   end;
   obj = {
	  "room4_mirror",
	  obj {
			-"цветы|розы/но";
		 nam = "room4_flowers";
		 dsc = "Весь остров в цветах.";
		 description = [[Прекрасные алые розы.]];
		 ["before_Take,Tear"] = function(s)
			mp:xaction('Take', _'room4_flower');
		end;
		before_Give = function(s, w)
			mp:xaction('Give', _'room4_flower', w);
		end;
		before_Show = function(s, w)
			mp:xaction('Show', _'room4_flower', w);
		end;
	  }: attr "static",
	  obj {
			-"флейта|дудка|дудочка|дуда";
		 nam = "flute";
		 init_dsc = "В траве лежит флейта.";
		 description = [[Изящная флейта, искусно вырезанная из слоновой кости.]];
		 --"брать"
		 Show = function(s, w)
		 	if w ^ "room4_mermaid" then
				return "Русалка смеётся, и делает жест, будто играет на флейте."
			end;
			return false;
		 end;
		 after_Take = "{#Me/им} {#word/брать,#me,нст} флейту.";
		 before_Smell = "Пахнет цветами.";
		 --"хотеть"
		 before_Taste = "{#Me/им} не {#word/хотеть,#me,нст} пробовать флейту на вкус.";
		 before_Touch = "Гладкая и приятная на ощупь.";
		 ["Blow,Use,Play"] = function(s)
			mp:check_held(s);
			if s:once() then
                           mp.score=mp.score+1
			   enable "room4_mermaid"
			   p "На переливы флейты из воды вынырнула настоящая русалка."
			else
			   p(mermaid_sing());
			end
		 end;
	  },
	  obj {
			-"цветок|роза/но";
		 nam = "room4_flower";
		 dsc = false,
		 donated = false,
		 description = "Прекрасная алая роза.";
		 ["before_Take,Tear"] = function(s)
			if have(s) or s.donated then
			   return "{#Me/дт} больше не нужны цветы. Да и жаль рвать такую красоту."
			else
			   take(s)
			   --"сорвать"
			   return "{#Me/им} {#word/сорвать,#me,прш} цветок."
			end
		 end;
		 Show = function(s, w)
		 	if w ^ "room4_mermaid" then
				return "Русалка радостно кивает, и показывает на свои волосы."
			end;

			return false;
		 end;
		 before_Give = function(s, w)
			mp:check_held(s);
			if w ^ "room4_mermaid" then
			   if not s.donated then
			          mp.score=mp.score+1
				  s.donated = true
				  place(s, here())
				  s:attr "scenery"
				  take "room4_sapfir"
				  take "room4_rybin"
				  take "room4_izymryd"
				  enable "room4_gems"
				  --"давать"
				  --"принимать"
				  p "{#Me/им} {#word/давать,#me,нст} русалке цветок. Она мило краснеет и забирает розу, тут же украшая ею свои волосы. Взамен она протягивает {#me/дт} три драгоценных камня: изумруд, сапфир и рубин. {#Me/им} с благодарностью {#word/принимать,#me,нст} их."
			   else
				  return "Русалке больше не нужны цветы."
			   end
			else
			   return "Кому-кому?"
			end
		 end;
	  },
	  obj {
			-"небо";
			description = "Ясное синее небо, ни облачка.";
			before_Take = "Взять небо? Как это возможно?";
			before_Smell = "Пахнет ветром и морем.";
			--"дотянуться"
			before_Taste = "Не {#word/дотянуться,#me,буд}.";
			before_Touch = "Жаль, не {#word/дотянуться,#me,буд}.";
	  }:attr "scenery",
	  obj {
		 -"солнце";
		description = "Яркое солнце, аж глазам больно на него смотреть.";
		before_Take = "Жаль нельзя запихнуть его в карман. Было бы здорово иметь своё карманное солнце.";
		before_Smell = "Отсюда {#me/им} не {#word/мочь,#me,нст} понять, чем пахнет солнце.";
		before_Taste = "Не {#word/дотянуться,#me,буд}.";
		before_Touch = "Жаль, не {#word/дотянуться,#me,буд}.";
	  }:attr "scenery",
	  obj {
			-"земля";
			--"замечать"
			description = "Земля заросла цветами. Присмотревшись, {#me/им} {#word/замечать,#me,нст} среди кустов роз человеческие кости.";
			before_Take = "{#Me/дт} не нужен здешний дёрн.";
			before_Smell = "Пахнет цветами и травой.";
			before_Taste = "Не {#word/хотеть,#me,нст} даже пробовать.";
			before_Touch = "Немного влажная, будто не так давно шёл дождь. Или был прилив, мхм...";
	  }:attr "scenery",
	  obj {
			-"трава";
			description = "Земля заросла цветами. Присмотревшись, {#me/им} {#word/замечать,#me,нст} в траве человеческие кости.";
			before_Take = "{#Me/дт} не нужна трава.";
			before_Smell = "Пахнет цветами и травой.";
			before_Taste = "Не {#word/хотеть,#me,нст} даже пробовать.";
			before_Touch = "Немного влажная, будто не так давно шёл дождь.";
	  }:attr "scenery",
	  obj {
			-"человеческие кости|кости/мн,но|человеческие останки|останки";
			description = "Множество человеческих костей. Да это могильник!";
			--"быть"
			before_Take = "Фу, {#me/им} не {#word/быть,#me,буд} к этому прикасаться.";
			before_Smell = "{#Me/им} не {#word/быть,#me,буд} это нюхать!";
			before_Taste = "Не {#word/хотеть,#me,нст} даже пробовать.";
			--"прикоснуться"
			before_Touch = "Ни за что к этому не {#word/прикоснуться,#me,буд}.";
	  }:attr "scenery",
	  obj {
			-"море|вода ";
			description = "Синее море, абсолютно прозрачное на мелководье. Красота неописуемая.";
			before_Take = "{#Me/дт} некуда налить воды.";
			before_Smell = "Пахнет свежестью и морскими водорослями.";
			before_Taste = "На вкус вода солёная, ничего особенного, да и жажду этим не утолишь.";
			before_Touch = "Вода ледяная, бррр... Странно, при такой-то жаре.";
	  }:attr "scenery",
	  obj {
			-"рама|фигурки,животные/од";
			description = "Бронзовая старинная рама. Украшена фигурками змеи, краба и дельфина.";
			before_Take = "Невозможно оторвать раму от зеркала.";
			before_Smell = "Пахнет металлом.";
			before_Taste = "На вкус, как металл.";
			before_Touch = "Прохладный металл.";
			before_Receive = "Лучше вставлять в каждую фигурку по отдельности.";
	  }:attr "scenery",
	  obj {
			-"драгоценные камни|камни|драгоценный камень|камень";
			nam = "room4_gems";
		description = "Красивые драгоценные камни, что дала {#me/дт} русалка.";
		before_Show = function(s, w)
		 	if w ^ "room4_mermaid" then
				return "Русалка кивает, и показывает пальчиком на висящее в воздухе зеркало."
			end;
			return "Камнями лучше распоряжаться по отдельности.";
		end;
		before_Take = function(s)
			if have "room4_izymryd" or have "room4_rybin" or have "room4_sapfir" then
				return "Они уже у {#me/рд}."
			else
				return false
			end
		end;
		before_Smell = "Пахнет красотой.";
		before_Taste = "На вкус, как стекло.";
		before_Touch = "Прохладные с идеальной огранкой.";
		before_Default = function(s, ev, w)
			if ev == 'Exam' then
				return false;
			end;
			p"Камнями лучше распоряжаться по отдельности.";
		end;
	  }:attr "scenery":disable(),
	  obj {
			-"русалка|ресницы|глаза|волосы|грудь";
		 nam = "room4_mermaid";
		 description = "Прекрасная русалка с длинными русыми волосами и большими томными глазами, обрамлёнными длинными пушистыми ресницами. Грудь прикрыта большими раковинами, скрепленными жемчугом. Морская дева по пояс высунулась из воды, и с интересом {#me/рд} рассматривает.";
		 ["Talk,Listen"] = function(s)
			--"пытаться"
			return [[{#Me/им} {#word/пытаться,#me,нст} поговорить с русалкой, но в ответ она лишь поёт:^
					ПрОклятое зеркало старого капитана^
					Затягивает всех, смотрящихся в стекло,^
					На остров одинокий средь злого океана,^
					Что стал могилой жуткой однажды для него.^
					Тот капитан - колдун, ловушку душ поставил,^
					Со Смертью заключив ужасный договор^
					За тысячу людей, что в бездну он отправил^
					Воскреснет вновь пират, продолжит свой террор.]];
		 end;
		 before_Remove = function(s, w)
			mp:xaction('Take',s);
		 end;
		 life_Give = function(s, w)
			--"нужен"
			   local things = {
				[[Русалка брезгливо скривила губки. ]],
				[[Русалка недовольно шлёпнула хвостом по воде, обдав {#me/вн} дождём солёных брызг. ]],
				[[Русалка отрицательно покачала головой. ]],
				}
			local r = rnd(#things)
			return things[r].."Ей не {#word/нужен,#second} {#second}."
		 end;
		 Kiss = "Русалка уклонилась от прикосновений, смущённо хихикнула и погрозила {#me/дт} пальчиком.";
	  }:attr "static,animate":disable(),
   };
}

obj {
	  -"сапфир";
   nam = "room4_sapfir";
   found_in = "emptyroom";
   description = [[Синий полупрозрачный драгоценный камень.]];
   before_Insert = function(s, w)
	  if not w ^ "room4_dolphin" then
		if w ^ "room4_crab" or w ^ "room4_frog" then
			return "Камень никак не хочет держаться в углублении."
		else
			return false
		end
	  end
	  place(s, w)
	  s:attr "scenery"
	  --"вставлять"
	    return "{#Me/им} {#word/вставлять,#me,нст} сапфир в углубление."
      end;
	Show = function(s, w)
	 	if w ^ "room4_mermaid" then
			return "Русалка кивает, и показывает пальчиком на висящее в воздухе зеркало."
		end;
		return false;
	end;
}

obj {
	  -"рубин";
   nam = "room4_rybin";
   found_in = "emptyroom";
   description = [[Сияющий красный драгоценный камень.]];
   before_Insert = function(s, w)
	  if not w ^ "room4_crab" then
		if w ^ "room4_dolphin" or w ^ "room4_frog" then
			return "Камень слишком большой и не влезает в углубление."
		else
			return false
		end
	  end
	  place(s, w)
	  s:attr "scenery"
	  return "{#Me/им} {#word/вставлять,#me,нст} рубин в углубление."
   end;
	Show = function(s, w)
	 	if w ^ "room4_mermaid" then
			return "Русалка кивает, и показывает пальчиком на висящее в воздухе зеркало."
		end;
		return false;
	end;
}

obj {
	  -"изумруд";
   nam = "room4_izymryd";
   found_in = "emptyroom";
   description = [[Зелёный блестящий драгоценный камень.]];
   before_Insert = function(s, w)
	  if not w ^ "room4_frog" then
		if w ^ "room4_crab" or w ^ "room4_dolphin" then
			return "Камень не подходит по форме к этому углублению."
		else
			return false
		end
	  end
	  place(s, w)
	  s:attr "scenery"
	  return "{#Me/им} {#word/вставлять,#me,нст} изумруд в углубление."
   end;
	Show = function(s, w)
	 	if w ^ "room4_mermaid" then
			return "Русалка кивает, и показывает пальчиком на висящее в воздухе зеркало."
		end;
		return false;
	end;
}

obj {
	  -"отверстие в фигурке дельфина/но|углубление в фигурке дельфин/но|дельфин/но";
   nam = "room4_dolphin";
   description = function(s)
	if where "room4_sapfir" ^ "room4_dolphin" then
		return "Бронзовая фигурка дельфина с переливающимся сапфиром во лбу."
	else
		return "Бронзовая фигурка дельфина с маленьким углублением во лбу."
	end
   end;
   before_LetIn = function(s, w)
	  --"подходит"
	  return "{#Second/им} не {#word/подходит,#second} по форме."
   end;
}:attr "static,container,open"

obj {
	  -"отверстие в фигурке краба/но|углубление в фигурке краба/но|краб/но|углубление/но";
   nam = "room4_crab";
   description = function(s)
	if where "room4_rybin" ^ "room4_crab" then
		return "Бронзовая фигурка краба с сияющим рубином в середине панциря."
	else
		return "Бронзовая фигурка краба с маленьким углублением в середине панциря."
	end
   end;
   before_LetIn = function(s, w)
	  --"подходит"
	  return "{#Second/им} не {#word/подходит,#second} по форме."
   end;
}:attr "static,container,open"

obj {
	  -"отверстие в фигурке змеи/но|углубление в фигурке змеи/но|змея/но";
   nam = "room4_frog";
   description = function(s)
	if where "room4_izymryd" ^ "room4_frog" then
		return "Бронзовая змея, с похожим на каплю блестящего яда, изумрудом во рту."
	else
		return "Бронзовая змея с маленьким углублением во рту."
	end
   end;
   before_LetIn = function(s, w)
	  --"подходит"
	  return "{#Second/им} не {#word/подходит,#second} по форме."
   end;
}:attr "static,container,open"

obj {
	  -"костяной ключ,ключ";
   nam = "bonekey";
   description = "Костяной ключ.";
	found_in = { 'room14_box1' };
        score=false;
        after_Take = function(s)
          if not s.score then
            mp.score=mp.score+1;
          end;
          _'bonekey'.score=true;
          return false;
        end;
}

game.hint_verbs = { "#Exam", "#Walk", "#Take", "#Drop" }
