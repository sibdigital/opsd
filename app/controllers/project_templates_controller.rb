class ProjectTemplatesController < ApplicationController
  include SortHelper
  include PaginationHelper
#  include CustomFieldsHelper
#  include QueriesHelper
#  include RepositoriesHelper
  include ProjectsHelper

  def index
    @templates = Project.templates

    respond_to do |format|
      format.atom do
        head(:gone)
      end
      format.html do
        render layout: 'no_menu'
      end
    end
  end

end
