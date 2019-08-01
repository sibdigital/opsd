#-- encoding: UTF-8
# This file written by BBM
# 26/04/2019

module DemoData
  class MemberSeeder < Seeder

    def initialize; end

    def seed_data!

      add_users
    end

    private

    def add_users
      default_role_project_curator = role_by_name (I18n.t(:default_role_project_curator))
      default_role_project_customer = role_by_name (I18n.t(:default_role_project_customer))
      default_role_project_office_manager = role_by_name (I18n.t(:default_role_project_office_manager))
      default_role_project_activity_coordinator = role_by_name (I18n.t(:default_role_project_activity_coordinator))
      default_role_project_office_coordinator = role_by_name (I18n.t(:default_role_project_office_coordinator))
      default_role_events_responsible = role_by_name (I18n.t(:default_role_events_responsible))
      default_role_project_head = role_by_name (I18n.t(:default_role_project_head))
      default_role_project_office_admin = role_by_name (I18n.t(:default_role_project_office_admin))
      default_role_member = role_by_name (I18n.t(:default_role_member))

      cultura = project_by_name "«Обеспечение качественно нового уровня развития инфраструктуры культуры» «Культурная среда» в Бурятии"
      umts = project_by_name "Переселение жителей микрорайонов «УМТС - Икибзяк» и «Механизированная колонна – 136» поселка Таксимо, Муйского района."
      gorod = project_by_name "Формирование комфортной городской среды."



      #global
      tas = user_by_login 'tas'
      set_project_member umts, tas, default_role_project_activity_coordinator
      set_project_member cultura, tas, default_role_project_activity_coordinator

      zii = user_by_login 'zii'
      set_project_member umts, zii, default_role_project_activity_coordinator
      set_project_member cultura, zii, default_role_project_activity_coordinator

      siv = user_by_login 'siv'
      set_project_member umts, siv, default_role_project_office_manager
      set_project_member cultura, siv, default_role_project_office_manager

      puts 'umts= ' + umts.to_s
      #umts
      lev = user_by_login 'lev'
      set_project_member umts, lev, default_role_project_curator

      rnu = user_by_login 'rnu'
      set_project_member umts, rnu, default_role_project_head

      doa = user_by_login 'doa'
      set_project_member umts, doa, default_role_project_office_coordinator

      ggo = user_by_login 'ggo'
      set_project_member umts, ggo, default_role_events_responsible

      ttv = user_by_login 'ttv'
      set_project_member umts, ttv, default_role_events_responsible

      moi = user_by_login 'moi'
      set_project_member umts, moi, default_role_events_responsible

      puts 'cultura= ' + cultura.to_s
      #cultura
      tvb = user_by_login 'tvb'
      set_project_member cultura, tvb, default_role_project_curator

      blb = user_by_login 'blb'
      set_project_member cultura, blb, default_role_project_head

      knn = user_by_login 'knn'
      set_project_member cultura, knn, default_role_project_office_coordinator

      tvs = user_by_login 'tvs'
      set_project_member cultura, tvs, default_role_events_responsible

      bdr = user_by_login 'bdr'
      set_project_member cultura, bdr, default_role_events_responsible

      puts 'gorod= ' + gorod.to_s
      #gorod
      lev = user_by_login 'lev'
      set_project_member gorod, lev, default_role_project_curator

      rnu = user_by_login 'rnu'
      set_project_member gorod, rnu, default_role_project_head

      doa = user_by_login 'doa'
      set_project_member gorod, doa, default_role_project_office_coordinator

      ggo = user_by_login 'ggo'
      set_project_member gorod, ggo, default_role_events_responsible

    end

    def work_package_by_subject(subject)
      np = WorkPackage.find_by(subject: subject)
      if np != nil
        np.id
      end
    end

    def project_by_name(name)
      np = Project.find_by(name: name)
      if np != nil
        np
      end
    end

    def role_by_name(name)
      np = Role.find_by(name: name)
      if np != nil
        np
      end
    end

    def user_by_login(login)
      np = User.find_by(login: login)
      if np != nil
        np
      end
    end

    def set_project_member(project, user, role)
      member = Member.new
      member.user_id = user.id
      member.project_id = project.id
      #member.roles = role
      member.add_and_save_role role
      #project.members << members
      #project.save
      member.save!(:validate => false)

      # member.user = user
      #member.add_role role
      # member.save
      # member.create_user
      #
       puts 'p:' + project.to_s
       puts 'id:' + member.to_s
      # puts 'u:' + member.user.to_s
    end
  end
end
