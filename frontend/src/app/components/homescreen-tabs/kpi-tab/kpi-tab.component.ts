import {Component, ViewChild} from "@angular/core";
import {AngularTrackingHelpers} from "core-components/angular/tracking-functions";
import {HomescreenBlueTableComponent} from "core-components/homescreen-blue-table/homescreen-blue-table.component";
import {HalResourceService} from "core-app/modules/hal/services/hal-resource.service";
import {PathHelperService} from "core-app/modules/common/path-helper/path-helper.service";
import {CollectionResource} from "core-app/modules/hal/resources/collection-resource";
import {HalResource} from "core-app/modules/hal/resources/hal-resource";
import {StateService} from "@uirouter/core";

interface ValueOption {
  name:string;
  dueDate:string;
  $href:number | null;
}

@Component({
  templateUrl: './kpi-tab.html'
})
export class KpiTabComponent {
  public dueDate:string = '';
  private value:{ [attribute:string]:any } | undefined = {};
  public valueOptions:ValueOption[] = [];
  public compareByHref = AngularTrackingHelpers.compareByHref;

  @ViewChild(HomescreenBlueTableComponent) blueChild:HomescreenBlueTableComponent;

  constructor(protected halResourceService:HalResourceService,
              protected pathHelper:PathHelperService,
              readonly $state:StateService) {
  }

  ngOnInit() {
    this.halResourceService.get<CollectionResource<HalResource>>(this.pathHelper.api.v3.projects_for_user.toString())
      .toPromise()
      .then((projects:CollectionResource<HalResource>) => {
        this.valueOptions = projects.elements.map((el:HalResource) => {
          return {
            name: el.name,
            dueDate: el.dueDate.due_date,
            $href: el.id
          };
        });
        this.valueOptions.unshift({name: 'Все проекты', dueDate: '', $href: 0});
        this.value = this.valueOptions[0];
        if (this.$state.params.id) {
          let option:ValueOption | undefined = _.find(this.valueOptions, o => String(o.$href) === this.$state.params.id);
          if (option !== undefined) {
            this.selectedOption = option;
          }
        }
      });
  }

  public get selectedOption() {
    const href = this.value ? this.value.$href : null;
    return _.find(this.valueOptions, o => o.$href === href)!;
  }

  public set selectedOption(val:ValueOption) {
    let option = _.find(this.valueOptions, o => o.$href === val.$href);
    this.value = option;
  }

  public handleUserSubmit() {
    if (this.selectedOption) {
      this.blueChild.changeFilter('project' + this.selectedOption.$href);
      this.dueDate = this.format(this.selectedOption.dueDate);
    }
  }

  public format(input:string):string {
    return input.slice(8, 10) + '.' + input.slice(5, 7) + '.' + input.slice(0, 4);
  }
}
