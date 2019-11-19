#created by bbm 18/11

class WorkPackages::CriticalWayService
  attr_accessor :user, :work_package, :project

  def initialize(user:, work_package:)
    self.user = user
    self.work_package = work_package
    self.project = work_package.project
  end

  def call
    CriticalWay.all.map do |cw|
      cw.on_crit_way = false
      cw.save
    end

    #Step1
    cwwps = project.work_packages
    min_step1 = cwwps.select { |wp| !wp.parent && wp.start_date}.min_by(&:start_date)
    ways = cwwps.select { |wp| !wp.parent && wp.start_date && wp.start_date == min_step1.start_date }
    @max = 0
    @way = []
    ways.map do |wp|
      if wp.due_date and wp.start_date
        durat = wp.due_date - wp.start_date
        step2(cwwps, wp.due_date + 1, [wp], durat)
      end
    end
    @way = @way.uniq

    @way.map do |wp|
      cw = wp.critical_way ? wp.critical_way : CriticalWay.create!(work_package: wp)
      cw.on_crit_way = true
      cw.save
    end
  end

  private

  def step2(cwwps, timeline, stack, length)
    min_step2 = cwwps.select { |wp| !wp.parent && wp.start_date && wp.start_date >= timeline}.min_by(&:start_date)
    if min_step2
      max_step2 = cwwps.select { |wp| !wp.parent && wp.start_date && wp.start_date == min_step2.start_date && wp.due_date}.max_by(&:due_date)
      ways = cwwps.select { |wp| !wp.parent && wp.start_date && wp.start_date == min_step2.start_date && wp.due_date && wp.due_date == max_step2.due_date }
      ways.map do |wp|
        stack << wp
        durat = wp.due_date - wp.start_date + 1
        step2(cwwps, wp.due_date + 1, stack, length + durat)
        stack.pop
      end
    elsif length == @max
      @way += stack
    elsif length > @max
      @max = length
      @way.replace(stack)
    end
  end
end
