#-- encoding: UTF-8

# This file written by BBM
# 16/07/2019

module API
  module V3
    module Diagrams
      class DiagramRepresenter < ::API::Decorators::Single
        def initialize(query: {}, params: {}, current_user:)
          @query = query

          @status = params[:status]?params[:status]['0']:nil
          @project = params[:project]?params[:project]['0']:nil
          @assignee = params[:assignee]?params[:assignee]['0']:nil
          @organization = params[:organization]?params[:organization]['0']:nil
          @date_begin = params[:dateBegin]
          @date_end = params[:dateEnd]
          @kpi_operation = params[:kpiOperation]
          @kpi_value = params[:kpiValue]

          @status_check = params[:statusCheck] || false;
          @project_check = params[:projectCheck] || false;
          @assignee_check = params[:assigneeCheck] || false;
          @organization_check = params[:organizationCheck] || false;
          @date_check = params[:dateCheck] || false;
          @kpi_check = params[:kpiCheck] || false;
          @seriex_select = params[:seriexSelect]?params[:seriexSelect]['0']:0 || 0
          @seriey_select = params[:serieySelect]?params[:serieySelect]['0']:0 || 0
          @serier_select = params[:serierSelect] || 0
          @bar_chart_type = params[:barChartType] || 'bar'
        end

        property :status_check,
                 exec_context: :decorator,
                 getter: ->(*) {
                   @status_check
                 },
                 render_nil: false

        property :project_check,
                 exec_context: :decorator,
                 getter: ->(*) {
                   @project_check
                 },
                 render_nil: false

        property :assignee_check,
                 exec_context: :decorator,
                 getter: ->(*) {
                   @assignee_check
                 },
                 render_nil: false

        property :organization_check,
                 exec_context: :decorator,
                 getter: ->(*) {
                   @organization_check
                 },
                 render_nil: false

        property :date_check,
                 exec_context: :decorator,
                 getter: ->(*) {
                   @date_check
                 },
                 render_nil: false

        property :kpi_check,
                 exec_context: :decorator,
                 getter: ->(*) {
                   @kpi_check
                 },
                 render_nil: false

        property :status,
                 exec_context: :decorator,
                 getter: ->(*) {
                   @status
                 },
                 render_nil: true

        property :project,
                 exec_context: :decorator,
                 getter: ->(*) {
                   @project
                 },
                 render_nil: true

        property :assignee,
                 exec_context: :decorator,
                 getter: ->(*) {
                   @assignee
                 },
                 render_nil: true

        property :organization,
                 exec_context: :decorator,
                 getter: ->(*) {
                   @organization
                 },
                 render_nil: true

        property :date_begin,
                 exec_context: :decorator,
                 getter: ->(*) {
                   @date_begin
                 },
                 render_nil: true

        property :date_end,
                 exec_context: :decorator,
                 getter: ->(*) {
                   @date_end
                 },
                 render_nil: true

        property :kpi_operation,
                 exec_context: :decorator,
                 getter: ->(*) {
                   @kpi_operation
                 },
                 render_nil: true

        property :kpi_value,
                 exec_context: :decorator,
                 getter: ->(*) {
                   @kpi_value
                 },
                 render_nil: true

        property :seriex_select,
                 exec_context: :decorator,
                 getter: ->(*) {
                   @seriex_select
                 },
                 render_nil: true

        property :seriey_select,
                 exec_context: :decorator,
                 getter: ->(*) {
                   @seriey_select
                 },
                 render_nil: true

        property :serier_select,
                 exec_context: :decorator,
                 getter: ->(*) {
                   @serier_select
                 },
                 render_nil: true

        property :bar_chart_type,
                 exec_context: :decorator,
                 getter: ->(*) {
                   @bar_chart_type
                 },
                 render_nil: true

        property :y,
                 exec_context: :decorator,
                 getter: ->(*) {
                   case @seriex_select
                   when 0 then
                     if @seriey_select == 0 then
                       Project.all.map(&:completed_percent_sd)
                     else
                       Project.all.map(&:total_wps)
                     end
                   else Project.all.map(&:total_wps)
                   end
                 },
                 render_nil: true

        property :x,
                 exec_context: :decorator,
                 getter: ->(*) {
                   case @seriex_select
                   when 0 then Project.all.map(&:name)
                   when 1 then Project.all.map(&:name)
                   else Project.all.map(&:name)
                   end
                 },
                 render_nil: true

        def _type
          'Diagram'
        end
      end
    end
  end
end
