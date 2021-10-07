-- Доступное пространство имён для объектов - все имена объектов должны начинаться с "room10_" или "zal_"
-- Все описания можно менять
-- Задача: Игрок должен найти в локации предмет lamp. Да-да, get lamp
room {
	nam = "room10_zal";
	title = "Зал";
	door_ask = false;
	dsc = [[Ты находишься в просторном зале. Широкая лестница в центре зала ведёт наверх. Два столба у основания
	лестницы венчают статуи в виде сидящих на перилах кошек. Свет от роскошной люстры освещает портреты на стенах.^^
	К северу расположена гостиная, к югу прихожая, на западе столовая. Лестница ведёт наверх.]];
	n_to = 'room12_gostinnaya';
	u_to = 'room14_secondfloor';
	s_to = 'room3_hall';
	w_to = 'room7_stolovaya';
        score=false;
	before_Any = function(s, ev, w)
		if me():where() ^ '#safe' or me():where() ^ '#podsobka' then
			if w and not w:access() then
				p ("Ты же в ", me():where():noun'пр', ".")
				return
			end
		end
		if not s.door_ask then
			return false
		end
		s.door_ask = false
		if ev == "Yes" then
			p [[Ты толкаешь дверь и она открывается! Что за кретин проектировал особняк?]]
			_'#podsobka':attr'open'
			_'#podsobka'.was_open = true
                        if not s.score then
                          mp.score=mp.score+1;
                        end;
                        _'room10_zal'.score=true;
			return
		elseif ev == "No" then
			p [[Да, вряд-ли кто-то в здравом уме стал бы проектировать двери таким образом.]]
			return
		end
		return false
	end;
	obj = {
		obj {
			-"столбы,столб*";
			description = [[Массивные деревянные столбы установлены в начале лестницы. На каждом столбе находятся небольшие статуи кошек.]];
		}:attr'scenery';
		obj {
			-"перила|стены/жр|потолок";
			description = function(s) p ("Тебе нет дела до ", s:noun'рд', ".") end;
		}:attr'scenery';
		obj {
			-"люстра|свет";
			description = [[Красивая люстра... Антиквариат?]];
		}:attr'concealed,static';
		obj {
			-"кошки,статуи/мн";
			description = "Небольшие фигурки кошек, вырезанные из дерева. А может быть, это слоновая кость? Тут есть правая кошка и левая кошка.";
		}:attr'concealed,static,~animate';
		obj {
			-"левая кошка,левая статуя,левая,кошка,статуя";
			description = [[Левая статуя изображает сидящую кошку. Она точно такая же, как и правая.]];
			['before_Push,Pull,Turn'] = 'Кошка не сдвинулась с места.';
		}:attr'static,concealed,~animate';
		obj {
			-"правая кошка,правая статуя,кошка,статуя,правая,потёрт*";
			description = function(s)
				if _'#safe':hasnt'locked' then
					p [[Правая статуя смотрит в сторону. Этот дом -- одна сплошная тайна!]]
					return
				end
				p [[Правая статуя изображает сидящую кошку. Она точно такая же, как и левая. Хотя, если приглядеться, то тебе кажется, что эта кошка имеет больше потёртостей и смотрит немного в другую сторону. Впрочем, это чувство может быть обманчивым.]];
			end;
			['before_Push,Pull,Touch'] = [[Гм... Тебе кажется, что кошка не зафиксирована жёстко на столбе. Ты чувствуешь это по еле заметным колебаниям, когда ты пытаешься сдвинуть её с места.]];
			['before_Turn'] = function(s)
				if _'#safe':hasnt'locked' then
					p [[Ты поворачиваешь кошку обратно.]]
					_'#safe':attr'locked'
				else
					p [[Ты пробуешь повернуть кошку вокруг своей оси. Получается! При этом, ты слышишь хорошо различимый щелчок.]]
					_'#safe':attr'~locked'
				end
			end;
		}:attr'static,concealed,~animate';
		obj {
			-"портреты|картины";
			before_Take = [[Тёте Агате это не понравится.]];
			description = function(s)
				p[[Скорее всего на портретах изображены предки тётушки Агаты. Если присмотреться к одному из них, то можно найти еле-уловимое сходство... Ах, да это же и есть тётушка Агата!]]
				enable '#portrait'
			end;
			['before_LookUnder,Push,Pull,Transfer,Turn'] = function(s)
				if not disabled '#portrait' then
					return false
				end
				p [[Ты решаешь проверить все портреты и педантично изучаешь каждый из них. Под портретом на котором изображена сама тётушка Агата ты обнаруживаешь тайник!]]
				enable '#portrait'
				enable '#safe'
				_'#portrait'.opened = true
			end;
		}:attr'scenery';
		obj {
			-"портрет|картина|тётушка,Агата";
			opened = false;
			nam = '#portrait';
			dsc = function(s)
				p [[Среди портретов на стенах ты видишь портрет тётушки Агаты.]];
				if s.opened then
					p [[Картина сдвинута, на её месте находится сейф.]]
				end
			end;
			before_Take = [[Тёте Агате это не понравится!]];
			description = [[Это твоя тётушка Агата. Как живая!]];
			['before_Push,Pull,Transfer,Turn,LookUnder'] = function(s)
				if s.opened then
					p [[Ты сдвигаешь картину обратно.]]
					s.opened = false
				else
					p [[Поддавшись своему чутью, ты заглядываешь под портрет и, конечно же, обнаруживаешь там сейф!]];
					s.opened = true
					enable '#safe'
				end
			end;
		}:attr'static,~animate':disable();
		obj {
			-"сейф,тайник";
			nam = '#safe';
			title = [[В сейфе]];
			description = function(s)
				if s:has'open' then
					p [[Сейф открыт!]]
					mp:content(s)
					return
				end
				p [[На сейфе нет никаких признаков замка или кодовых ручек.]]
			end;
			before_Close = function(s)
				if me():where() == s and s:has'open' then
					p [[А если дверь не откроется?]]
					return
				end
				return false
			end;
			before_Enter = function(s)
				if s:has'open' then
					p [[Укрыться от всех невзгод в сейфе? Хороший план!]];
					return false
				else
					return false
				end
			end;
		}:attr 'scenery,openable,enterable,locked,container':disable():with {
			obj {
				-"сокровища|брильянты,алмазы|украшения|сокровище,золото,клад";
				description = [[Столько усилий и всё зря! Похоже, это неприкосновенный запас тётушки... Ты видишь тут: брильянты, золото, ювелирные украшения... Ты разочарована.]];
				before_Take = [[Грабить тётушку? Ты в своём уме? Пусть тут лежит.]];
				before_Enter = [[Что за пошлая мысль?]];
			}:attr'static';
		};
		door {
		-"лестница,ступен*";
		description = function(s)
			p [[Построено с размахом! На ступенях закреплена красная ковровая дорожка.]];
			if _'#podsobka':has'concealed' then
				_'#podsobka':attr'~concealed'
				p [[Под лестницей ты замечаешь небольшую дверь в подсобку.]]
			end
		end;
		before_LookUnder = function(s)
			_'#podsobka':attr'~concealed'
			p [[Под лестницей ты замечаешь небольшую дверь в подсобку.]]
		end;
		door_to = function(s)
			return std.call(here(), 'u_to')
		end;
		}:attr'scenery,open':with {
			obj {
			-"ковёр|ковровая дорожка,дорожка,красн*";
			description = function(s)
				p [[Это так в духе тётушки Агаты. Её любовь к роскоши выглядит скорее наивной, чем напыщенной.]];
				mp:content(s)
			end;
			before_Take = [[Дорожка надёжно закреплена.]];
			['before_Enter,Climb'] = [[Если хочешь подняться по лестнице, просто иди наверх.]];
			}:attr 'enterable,static'
		};
		obj {
			-"подсобка,кладовка,дверь,дверь подсобки,дверь в подсобку";
			nam = '#podsobka';
			title = [[В подсобке.]];
			inside_dsc = [[Ты находишься в подсобке.]];
			was_open = false;
			dsc = function(s)
				if s:hasnt'open' then
					p [[Под лестницей расположена дверь в подсобку.]];
				else
					p [[Дверь в подсобку открыта.]]
					mp:content(s)
				end
			end;
			description = function(s)
				if s:hasnt'open' then
					p [[Небольшая деревянная дверь подсобки закрыта. Замочной скважины не видно. Дверь без замка?]]
					return
				end
				return false
			end;
			["before_Open,Pull"] = function(s)
				if s:has'open' or s.was_open then
					return false
				end
				if s:once('1') then
					p [[Ты подёргала дверь. Не поддаётся. Странно.]];
				elseif s:once('2') then
					p [[Ты с силой дёргаешь дверь. Нет результата.]];
				else
					p [[Ты изо всех сил тянешь дверь на себя. Не открывается!]];
				end
			end;
			before_Attack = function(s)
				if s:has'open' then
					return false
				end
				p [[Ты не чувствуешь себя способной выломать эту дверь.]]
			end;
			before_Push = function(s)
				if s:has'open' then
					mp:xaction("Open", s)
					return
				end
				here().door_ask = true
				p [[Ха! Думаешь, дверь открывается в другую сторону? {$fmt em|Да?}]]
			end;
		}:attr'container,openable,enterable,concealed,static': with { 'lamp' };
	};
}

-- Менять нельзя!!!! Это не ваш предмет!!! Вы не знаете как он выглядит, его придумает другой автор!!!
obj {
	-"керосиновая лампа, лампа, старая лампа";
	nam = "lamp";
	kerosin = 0;
	description = function (s)
          p "Обычная керосиновая лампа.";
          if s.kerosin==0 then
            p "В ней нет керосина.";
          else
            p "Заправлена керосином.";
          end;
          if (s :has 'light') then
            p "Горит и светит.";
          else
            p "Не горит.";
          end;
        end;
        before_Fill = function(s,w)
	  if not w and _'kerosin':access() then
            mp:check_held(_'kerosin');
	  elseif w then
            mp:check_held(w);
	  end;
          if not w and not have('kerosin') then
            p "Тебе нечем наполнить лампу!";
          elseif w and not w^'kerosin' then
            return false;
          else
            _'lamp'.kerosin = 1;
            remove ('kerosin');
            p "Ты заправляешь лампу керосином, и избавляешься от опустевшей бутылочки.";
          end
        end;
        before_Burn = function(s,w)
          if not w then
             p "Чем ты хочешь зажечь лампу?";
             return true;
          end
          if not w^'matches' and not w^'kitchen_lighter' then
            p "Этим не зажечь лампу!";
          elseif w^'matches' then
            if s.kerosin==0 then
              p "Не выйдет! В лампе совершенно не осталось керосина! Сначала ее стоило бы наполнить чем-то горючим.";
              return true;
            end
            _'lamp':attr'light';
            remove ('matches');
            mp.score=mp.score+1;
            p "Ты поджигаешь лампу от последней спички.";
          else
            p "Зажигалка слишком толстая и не влазит в узкое горло керосиновой лампы.";
          end
        end;
        before_Rub = "Ты потёрла старую лампу, но ничего не произошло, и никакого джина из неё не вылезло. Попытаться, впрочем, стоило.";
        score=false;
        after_Take = function(s)
          if not s.score then
            mp.score=mp.score+1;
          end;
          _'lamp'.score=true;
          return false;
        end;
};

VerbExtend {"#Fill",
	"в {noun}/вн {noun}/вн : Fill",
	"~ внутрь {noun}/рд {noun}/вн : Fill",
	"~ {noun}/вн {noun}/тв : Fill",
	"~ {noun}/вн в {noun}/вн : Fill reverse",
	"~ {noun}/вн внутрь {noun}/рд : Fill reverse",
	"~ {noun}/тв {noun}/вн : Fill reverse"
}

function mp:after_Fill(w,wh)
	if wh then
		mp:message 'Fill.FILL2'
	else
		mp:message 'Fill.FILL'
	end
end
mp.msg.Fill.FILL2 = "Наполнять {#first/вн} {#second/тв} бессмысленно."
