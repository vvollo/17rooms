--Автор: Андрей Лобанов

room {
   -"библиотека",
	nam = "room13_library",
	title = "Библиотека",
	dsc = function(s)
	   local v = " На западе расположена гостиная."
	   if s:once() then
		  --"вошёл"
		  --"мечтаешь"
		  return "{#Me/им} {#word/вошёл,#me,прш} в библиотеку. Очень уютное и приятное помещение. О такой библиотеке {#me} {#word/мечтаешь,#me,прш} в детстве." .. v
	   end
	   --"находится"
	   return "{#Me/им} {#word/находится,#me,нст} в библиотеке." .. v
	end,
	description = "Небольшая, по меркам особняка тёти Агаты, комната.",
	w_to = 'room12_gostinnaya',
	out_to = 'room12_gostinnaya',
	onexit = function(s)
		if not _"book".score or not _"squarekey".score then
			p "Тебе почему-то кажется, что библиотека ещё не открыла все свои секреты."
		end
	end,
	Taste = "{#Me} не {#word/хочет,#me,нст} пробовать {#first/вн} на вкус.",
	obj = {
	   obj {
			 -"шкафы|шкаф",
		  nam = "room13_шкафы",
		  moved = false,
		  dsc = "Вдоль стен стоят шкафы с книгами.",
		  description = "Гигантские шкафы от пола до потолка. Полны книг. До верхних полок не дотянуться без специальной лесенки.",
		  --"поднимешь"
		  before_Take = "Шкафы огромны и тяжелы. {#Me/им} никогда не {#word/поднимешь,#me,буд} такой даже если он будет пустой.",
		  Smell = "Пахнут бумажной пылью.",
		  Touch = "Шкафы приятные на ощупь. Настоящая древесина.",
		  obj = {
			 obj {
				   -"книги,корешки",
				description = "Корешки книг подобраны так, что вызывают ощущение идеального порядка в библиотеке. Как будто библиотеку подбирал дизайнер. Здесь есть чтиво на любой вкус.",
				--"провёл"
				Touch = "{#Me/им} {#word/провёл,#me,прш} рукой по корешкам книг.",
				--"пахнет"
				Smell = "{#First/им} не {#word/пахнет,#first,нст} ничем особенным.",
				Taste = "{#Me/им} не {#word/хочет,#me,нст} пробовать {#fitst} на вкус.",
				--"попробовать"
				before_Take = "{#Me} {#word/попробовать,#me,прш} взять книгу. Не поддаётся как будто приклеена.^^Возможно стоит изучить библиотеку повнимательнее.",
				--"пахнет"
				Smell = "{#First/им} {#word/пахнет,#first,нст} старой бумагой.",
				--"приятный"
				Touch = "{#First/им} {#word/приятный,#first,нст} на ощупь.",
				--"хочет"
				["before_Consult,Search"] = function(s)
				   if disabled "room13_тайный рычаг" then
					  enable "room13_тайный рычаг"
					  mp.score=mp.score+1
					  --"замечает"
					  return "Хорошенько осмотрев книги, {#me} {#word/замечает,#me,нст} что одна книга выглядит более потёртой, чем остальные. Должно быть это тайный рычаг."
				   else
					  return "Одна книга выглядит более потёртой, чем остальные. Это тайный рычаг."
				   end
				end,
			 }:attr "scenery",
			 obj {
				   -"рычаг|тайный рычаг|потёртая книга,книга",
				nam = "room13_тайный рычаг",
				description = "Книга выглядит более потёртой, чем все остальные книги в библиотеке.",
				--"попробовал"
				before_Take = "{#Me} {#word/попробовал,#me,прш} взять тайный рычаг, но он крепко закреплён в шкафу.",
				Touch = function(s)
				   s:Pull(s)
				end,
				Smell = "{#First} не {#word/пахнет,#first,нст} ничем примечательным.",
				USED = function(s)
                                   if _"room13_шкафы".moved==false then
  				      mp.score=mp.score+1
  				   end;
				   _"room13_шкафы".moved = true
				   enable "room13_дверца"
				   pn()
				   p "Один из шкафов с шуршанием отъехал в сторону. За ним обнаружилась маленькая дверца."
				end,
				--"потянуть"
				Pull = function(s)
                                   if _"room13_шкафы".moved then
  				      p "Рычаг уже выполнил свою функцию."
  				      return
  				   end;
				   pn "{#Me/им} {#word/потянуть,#me,прш} рычаг."
				   s.USED(s)
				end,
				--"нажать"
				Push = function(s)
                                   if _"room13_шкафы".moved then
  				      p "Рычаг уже выполнил свою функцию."
  				      return
  				   end;
				   pn "{#Me/им} {#word/нажать,#me,прш} рычаг."
				   s.USED(s)
				end,
			 }:attr "static":disable(),
		  },
	   }:attr "static,container,open",
	   obj {
			 -"дверца|маленькая дверца|дверка|маленькая дверка|дверь",
		  nam = "room13_дверца",
		  dsc = function(s)
			p "За отъехавшим в сторону шкафом видна маленькая дверца."
			mp:content(s)
		  end,
		  description = "Маленькая металлическая дверца.",
		  before_Take = function(s)
			 if disabled "room13_ниша" then
				return "{#Me/им} {#word/попробовал,#me,прш} взять дверцу, но она слишком плотно прилегает к стене -- невозможно зацепить."
			 end
			 --"подёргал"
			 return "{#Me/им} {#word/подёргал,#me,прш} дверцу, но она крепко держится на петлях."
		  end,
		  Touch = "{#First/им} прохладная и гладкая.",
		  Smell = "{#First/им} пахнет металлом.",
		  with_key = "room13_маленький ключик",
		  before_Receive = function(s, w)
			 mp:xaction("Insert", w, _"room13_ниша");
		  end;
		  after_Unlock = function(s)
			 remove "room13_маленький ключик"
			 return false
		  end,
		  obj = {
			   obj {
					 -"ниша",
				  nam = "room13_ниша",
				  dsc = function(s)
					 p "За ней находится небольшая ниша."
					 mp:content(s)
				  end,
				  description = function(s)
					 p "Небольшое углубление в стене. Тайник!"
					 mp:content(s)
				  end,
				  --"знает"
				  before_Take = "{#Me} не {#word/знает,#me,нст} как можно взять нишу.",
				  Touch = "Внутри ниша обита мягким и приятным на ощупь материалом.",
				  Smell = "В нише ничем не пахнет.",
				  obj = {
					 "book",
				  },
			   }:attr "static,container,open",
		  },
	   }:attr "static,openable,lockable,locked,container":disable(),
	   obj {
			 -"ковёр|коврик",
		  count = 0,
		  dsc = "На деревянном полу лежит небольшой коврик.",
		  description = function(s)
			 s.count = s.count + 1
			 if s.count > 3 then
				return "Возможно, под ковриком что-то лежит."
			 end
			 return "Небольшой коврик с коротким ворсом."
		  end,
		  before_Take = "{#Me/дт} не нужен коврик. Пусть лучше лежит на месте.",
		  Touch = "Короткий ворс ковра мягкий и приятно проминается под рукой.",
		  Smell = "Ничем особенным не пахнет.",
		  LookUnder = function(s)
			 if s:once() then
				take "room13_маленький ключик"
				--"нашёл"
				--"взял"
				return "{#Me/им} {#word/нашёл,#me,прш} маленький ключик под ковриком.^^{#Me/им} {#word/взял,#me,прш} маленький ключик."
			 else
				return "Больше под ковриком ничего нет."
			 end
		  end,
	   }:attr "static",
	   obj {
			 -"окно|рама",
		  dsc = "В длинной стене расположено окно.",
		  description = "Красивая оконная рама из морёного дерева и чистое, как будто его только что вымыли, стекло. Узкий деревянный подоконник выглядит очень уютно.",
		  Search = "За окном видно улицу.",
		  --"подёргал"
		  before_Take = "{#Me/им} {#word/подёргал,#me,прш} {#first}. Крепко дёржится.",
		  before_Open = "{#Me} {#word/попробовать,#me,прш} открыть окно, но оно не открывается.",
		  Smell = "Рама окна немного пахнет старым деревом.",
		  Touch = "Стекло гладкое и прохладное.",
		  obj = {
			 obj {
				   -"стекло",
				description = "Чистое стекло.",
				--"хочет"
				before_Take = "{#Me} не {#word/хочет,#me,нст} вытаскивать стекло из рамы.",
				Touch = "Стекло гладкое и прохладное.",
				Smell = "Стекло ничем не пахнет.",
			 }:attr "scenery",
			 obj {
				   -"подоконник",
				description = "На краю подоконника виднеется небольшой выступ.",
				before_Take = "Крепко закреплён -- не оторвать.",
				Touch = "Подоконник гладкий на ощупь.",
				Smell = "Подоконник пахнет деревом.",
				["Enter,Climb"] = "Удобно устроиться на подоконнике мешает торчащий сбоку выступ.",
				obj = {
				   obj {
						 -"выступ|кнопка",
					  description = "Небольшой выступ похожий на маленькую кнопку.",
					  before_Take = "Выступ крепко держится в подоконнике.",
					  ["Touch,Push"] = function(s)
						 if disabled "room13_тайник" then
							enable "room13_тайник"
							--"нажал"
							return "{#Me} {#word/нажал,#me,прш} на кнопку. Часть поверхности подоконника откинулась вверх, открывая тайник."
						 end
						 return "{#Me} {#word/нажал,#me,прш} на кнопку. Ничего не произошло."
					  end,
					  Smell = "Пахнет деревом, как и весь подоконник.",
				   }:attr "scenery",
				},
			 }:attr "scenery,container,open",
			 obj {
				   -"крышка|пластина|пластинка",
				description = "Тонкая деревянная пластинка, очень плотно закрывающая тайник",
				before_Take = "Пластинка крепко держится на маленьких петлях.",
				Touch = "Гладкая тонкая деревянная пластинка.",
				Smell = "Пахнет деревом.",
			 }:attr "scenery",
			 obj {
				   -"улица|улочка",
				description = "Узкая, но уютная улочка.",
				--"может"
				before_Take = "{#Me/им} не {#word/может,#me,нст} взять улицу.",
				Touch = "Улица находится за окном. Её невозможно потрогать.",
				Smell = "Окно закрыто. Запах с улицы не проникает в библиотеку.",
			 }:attr "scenery",
		  },
	   }:attr "static",
	   obj {
			 -"тайник|углубление",
		  nam = "room13_тайник",
		  dsc = function(s)
			 p "В подоконнике находится тайник."
			 mp:content(s)
		  end,
		  description = function(s)
			p "Небольшое углубление в подоконнике, обычно закрытое тонкой деревянной крышкой."
			mp:content(s)
		  end,
		  before_Take = "Это просто углубление в доске. Как его взять?",
		  Touch = "Внутри углубления дерево такое же гладкое, как и на поверхности подоконника. Кто-то очень аккуратно сделал этот тайник.",
		  Smell = "Пахнет деревом.",
		  obj = {
			 "squarekey"
		  },
	   }:attr "static,container,open":disable(),
	   obj {
			 -"стены|стена",
		  description = "Стены покрывают красивые старинные обои.",
		  before_Take = "Невозможно взять стены.",
		  --"дотронулся"
		  Touch = "{#Me/им} {#word/дотронулся,#me,прш} до стены. Гладкие обои приятны на ощупь.",
		  Smell = "Пахнет старыми обоями.",
	   }:attr "scenery",
	   obj {
			 -"обои",
		  description = "Тёмные обои с красивым золотистым узором.",
		  --"хочет"
		  before_Take = "{#Me/им} не {#word/хочет,#me,нст} отрывать обои от стен.",
		  Touch = "{#Me/им} {#word/дотронулся,#me,прш} до стены. Гладкие обои приятны на ощупь.",
		  Smell = "Пахнет старыми обоями.",
	   }:attr "scenery",
	   obj {
			 -"пол|паркет",
		  description = "Пол устилает старинный паркет.",
		  before_Take = "Как можно взять пол?",
		  Touch = "Старинные доски приятно скользят под пальцами.",
		  Smell = "{#Me/им} не {#word/хочет,#me,нст} нюхать пол.",
	   }:attr "scenery",
	   obj {
			 -"потолок",
		  description = "Белый потолок с лепниной. Красиво как в музее.",
		  before_Take = "Потолок находится слишком высоко. Да и как его можно взять?",
		  Touch = "Потолок находится слишком высоко. Не допрыгнуть.",
		  Smell = "Потолок находится так высоко, что остаётся только гадать чем же он пахнет.",
	   }:attr "scenery",
	},
}

obj {
	  -"ключик|маленький ключик",
   nam = "room13_маленький ключик",
   description = "Маленький ключик из белого металла.",
   Touch = "Гладкий белый металл приятно холодит руку.",
   Smell = "Пахнет металлом.",
}
