#-- encoding: UTF-8
# This file written by XCC
# 22/06/2019

module BasicData
  class RaionSeeder < Seeder
    def seed_data!
      ActiveRecord::Base.connection.execute(script())
    end

    def applicable?
      Raion.all.empty?
    end


    def script

      "insert into raions(name, code, sort_code) values
        ('Баргузинский район','01',1),
        ('Баунтовский эвенкийский район','02',2),
        ('Бичурский район','03',3),
        ('Джидинский район','04',4),
        ('Еравнинский район','05',5),
        ('Заиграевский район','06',6),
        ('Закаменский район','07',7),
        ('Иволгинский район','08',8),
        ('Кабанский район','09',9),
        ('Кижингинский район','10',10),
        ('Курумканский район','11',11),
        ('Кяхтинский район','12',12),
        ('Муйский район','13',13),
        ('Мухоршибирский район','14',14),
        ('Окинский район','15',15),
        ('Прибайкальский район','16',16),
        ('Северо-Байкальский район','17',17),
        ('Селенгинский район','18',18),
        ('Тарбагатайский район','19',19),
        ('Тункинский район','20',20),
        ('Хоринский район','21',21),
        ('г. Улан-Удэ','22',22),
        ('г. Северобайкальск','23','23')
      "

    end

  end
end
