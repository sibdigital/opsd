#-- encoding: UTF-8
# bbm
#++

class WorkPackages::ScheduleDependencySS
  def initialize(work_packages)
    self.work_packages = Array(work_packages)
    self.dependencies = {}
    self.known_work_packages = self.work_packages

    build_dependencies
  end

  def each
    unhandled = dependencies.keys

    while unhandled.any?
      movement = false
      dependencies.each do |scheduled, dependency|
        next unless unhandled.include?(scheduled)
        next unless dependency.met?(unhandled)

        yield scheduled, dependency

        unhandled.delete(scheduled)
        movement = true
      end

      raise "Circular dependency" unless movement
    end
  end

  attr_accessor :work_packages,
                :dependencies,
                :known_work_packages,
                :known_work_packages_by_id,
                :known_work_packages_by_parent_id

  private

  def build_dependencies
    load_commonstart(work_packages)
  end

  def load_all_commonstart(work_packages)
    commonstart = load_commonstart(work_packages)

    # Those variables are pure optimizations.
    # We want to reuse the already loaded work packages as much as possible
    # and we want to have them readily available as hashes.
    self.known_work_packages += commonstart
    known_work_packages.uniq!
    self.known_work_packages_by_id = known_work_packages.group_by(&:id)
    self.known_work_packages_by_parent_id = known_work_packages.group_by(&:parent_id)

    new_dependencies = add_dependencies(commonstart)

    if new_dependencies.any?
      load_all_commonstart(new_dependencies.keys)
    end
  end

  def load_commonstart(work_packages)
    commonstart = Relation.direct.of_work_package(work_packages).where('commonstart > 0')

    WorkPackage
      .where("id IN (SELECT common_id FROM (#{commonstart.to_sql}) commonstart_relations)")
      .includes(:custom_values,
                :attachments,
                :type,
                :project,
                :journals,
                parent_relation: :from,
                commonstart_relations: :from,
                commonstart_relations: :to)
  end

  def find_moved(candidates)
    candidates.select do |following, dependency|
      dependency.ancestors.any? { |ancestor| included_in_follows?(ancestor, candidates) } ||
        dependency.descendants.any? { |descendant| included_in_follows?(descendant, candidates) } ||
        dependency.descendants.any? { |descendant| work_packages.include?(descendant) } ||
        included_in_follows?(following, candidates)
    end
  end

  def included_in_follows?(wp, candidates)
    tos = wp.follows_relations.map(&:to)

    dependencies.slice(*tos).any? ||
      candidates.slice(*tos).any? ||
      (tos & work_packages).any?
  end

  def add_dependencies(dependent_work_packages)
    added = dependent_work_packages.inject({}) do |new_dependencies, dependent_work_package|
      dependency = Dependency.new dependent_work_package, self

      new_dependencies[dependent_work_package] = dependency

      new_dependencies
    end

    moved = find_moved(added)

    newly_added = moved.except(*dependencies.keys)

    dependencies.merge!(moved)

    newly_added
  end

  class Dependency
    def initialize(work_package, schedule_dependency)
      self.schedule_dependency = schedule_dependency
      self.work_package = work_package
    end

    def ancestors
      @ancestors ||= ancestors_from_preloaded(work_package)
    end

    def descendants
      @descendants ||= descendants_from_preloaded(work_package)
    end

    def follows_moved
      tree = ancestors + descendants

      @follows_moved ||= moved_predecessors_from_preloaded(work_package, tree)
    end

    def follows_unmoved
      tree = ancestors + descendants

      @follows_unmoved ||= unmoved_predecessors_from_preloaded(work_package, tree)
    end

    attr_accessor :work_package,
                  :schedule_dependency

    def met?(unhandled_work_packages)
      (descendants & unhandled_work_packages).empty? &&
        (follows_moved.map(&:to) & unhandled_work_packages).empty?
    end

    def max_date_of_followed
      (follows_moved + follows_unmoved)
        .map(&:successor_soonest_start)
        .compact
        .max
    end

    def start_date
      descendants_dates.min
    end

    def due_date
      descendants_dates.max
    end

    private

    def descendants_dates
      (descendants.map(&:due_date) + descendants.map(&:start_date)).compact
    end

    def ancestors_from_preloaded(work_package)
      if work_package.parent_id
        parent = known_work_packages_by_id[work_package.parent_id]

        if parent
          parent + ancestors_from_preloaded(parent.first)
        end
      end || []
    end

    def descendants_from_preloaded(work_package)
      children = known_work_packages_by_parent_id[work_package.id] || []

      children + children.map { |child| descendants_from_preloaded(child) }.flatten
    end

    delegate :known_work_packages,
             :known_work_packages_by_id,
             :known_work_packages_by_parent_id, to: :schedule_dependency

    def scheduled_work_packages
      schedule_dependency.work_packages + schedule_dependency.dependencies.keys
    end

    def moved_predecessors_from_preloaded(work_package, tree)
      ([work_package] + tree)
        .map(&:follows_relations)
        .flatten
        .map do |relation|
          scheduled = scheduled_work_packages.detect { |c| relation.to_id == c.id }

          if scheduled
            relation.to = scheduled
            relation
          end
        end
        .compact
    end

    def unmoved_predecessors_from_preloaded(work_package, tree)
      ([work_package] + tree)
        .map(&:follows_relations)
        .flatten
        .reject do |relation|
          scheduled_work_packages.any? { |m| relation.to_id == m.id }
        end
    end
  end
end
