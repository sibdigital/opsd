module Members
  class RowCell < ::RowCell
    property :user

    def member
      model
    end

    def row_css_id
      "member-#{member.id}"
    end

    def row_css_class
      group = user ? "" : "group"

      "member #{group}".strip
    end

    def lastname
      if user
        link_to user.lastname, user_path(user)
      else
        member.name + " (Группа)"
      end
    end

    def firstname
      link_to user.firstname, user_path(user) if user
    end

    #zbd(
    def patronymic
      link_to user.patronymic, user_path(user) if user
    end
    #)

    def phone_wrk
      user.phone_wrk if user
    end

    def mail
      if user
        link = mail_to(user.mail)

        if member.user && member.user.invited?
          i = content_tag "i", "", title: t("text_user_invited"), class: "icon icon-mail1"

          link + i
        else
          link
        end
      end
    end

    def busyness
      label = member.busyness
      span = content_tag "span", label, id: "member-#{member.id}-busyness"

      if may_update?
        span + busyness_form_cell.call
      else
        span
      end
    end

    def roles
      label = h member.roles.sort.collect(&:name).join(', ')
      span = content_tag "span", label, id: "member-#{member.id}-roles"

      if may_update?
        span + role_form_cell.call
      else
        span
      end
    end

    def busyness_form_cell
      Members::BusynessFormCell.new(
        member,
        row: self,
        params: controller.params,
        busyness: member.busyness,
        context: { controller: controller }
      )
    end

    def role_form_cell
      Members::RoleFormCell.new(
        member,
        row: self,
        params: controller.params,
        roles: table.available_roles,
        context: { controller: controller }
      )
    end

    def groups
      if user
        user.groups.map(&:name).join(", ")
      else
        model.principal.name
      end
    end

    def status
      I18n.t("status_#{model.principal.status_name}")
    end

    def may_update?
      table.authorize_update
    end

    def button_links
      if may_update?
        [edit_link, delete_link].compact
      else
        []
      end
    end

    def edit_link
      link_to(
        op_icon('icon icon-edit'),
        '#',
        class: "toggle-membership-button #{toggle_item_class_name}",
        data: { 'toggle-target': ".#{toggle_item_class_name}" },
        title: t(:button_edit)
      )
    end

    def roles_css_id
      "member-#{member.id}-roles"
    end

    def busyness_css_id
      "member-#{member.busyness}-busyness"
    end

    def toggle_item_class_name
      "member-#{member.id}--edit-toggle-item"
    end

    def delete_link
      if model.deletable?
        link_to(
          op_icon('icon icon-delete'),
          { controller: '/members', action: 'destroy', id: model, page: params[:page] },
          method: :delete,
          data: { confirm: delete_link_confirmation },
          title: delete_title
        )
      end
    end

    def delete_title
      if model.disposable?
        I18n.t(:title_remove_and_delete_user)
      else
        I18n.t(:button_remove)
      end
    end

    def delete_link_confirmation
      if !User.current.admin? && model.include?(User.current)
        t(:text_own_membership_delete_confirmation)
      end
    end

    def column_css_class(column)
      if column == :mail
        "email"
      else
        super
      end
    end
  end
end
