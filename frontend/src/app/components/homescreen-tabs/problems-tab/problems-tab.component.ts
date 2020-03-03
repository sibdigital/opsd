import {Component, ViewChild} from "@angular/core";
import {HomescreenBlueTableComponent} from "core-components/homescreen-blue-table/homescreen-blue-table.component";
import {AngularTrackingHelpers} from "core-components/angular/tracking-functions";
import {HalResourceService} from "core-app/modules/hal/services/hal-resource.service";
import {PathHelperService} from "core-app/modules/common/path-helper/path-helper.service";
import {CollectionResource} from "core-app/modules/hal/resources/collection-resource";
import {HalResource} from "core-app/modules/hal/resources/hal-resource";
import {StateService} from "@uirouter/core";
import {WorkPackageResource} from "core-app/modules/hal/resources/work-package-resource";

interface ValueOption {
  name:string;
  kurator:string;
  rukovoditel:string;
  $href:number | null;
}

@Component({
  templateUrl: './problems-tab.html'
})
export class ProblemsTabComponent {
  public curator:string = '';
  public ruk:string = '';
  keyword = 'name';
  data_autocomplete:any[] = [];
  data_choosed:any;
  is_loading:boolean[] = [true];
  private value:{ [attribute:string]:any } | undefined = {};
  public valueOptions:ValueOption[] = [];
  public compareByHref = AngularTrackingHelpers.compareByHref;

  @ViewChild(HomescreenBlueTableComponent) blueChild:HomescreenBlueTableComponent;
  @ViewChild('autocomplete') auto:any;

  constructor(protected halResourceService:HalResourceService,
              protected pathHelper:PathHelperService,
              readonly $state:StateService) {
  }

  ngOnInit() {
    this.halResourceService.get<CollectionResource<HalResource>>(this.pathHelper.api.v3.projects_for_user.toString())
      .toPromise()
      .then((projects:CollectionResource<HalResource>) => {
        this.valueOptions = projects.elements.map((el:HalResource) => {
          this.data_autocomplete.push({id: el.id, name: el.name, kurator: el.curator ? el.curator.fio : '', rukovoditel: el.rukovoditel ? el.rukovoditel.fio : ''});
          return {name: el.name, kurator: el.curator ? el.curator.fio : '', rukovoditel: el.rukovoditel ? el.rukovoditel.fio : '' , $href: el.id};
        });
        this.valueOptions.unshift({name: 'Все проекты', kurator: '-', rukovoditel:'-', $href: 0});
        this.value = this.valueOptions[0];
        if (this.$state.params.id) {
          let option:ValueOption | undefined = _.find(this.valueOptions, o => String(o.$href) === this.$state.params.id);
          if (option !== undefined) {
            this.selectedOption = option;
          }
        }
        this.is_loading[0] = false;
      });
  }

  public check_load() {
    // console.log(this.is_loading);
    return this.is_loading[0];

    // let is_ready = true;
    // this.is_loading.forEach(value => (is_ready = value || is_ready));
    // return is_ready;
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
      this.curator = this.selectedOption.kurator;
      this.ruk = this.selectedOption.rukovoditel;
    }
  }

  selectEvent(item:any) {
    this.auto.close();
    this.is_loading[0] = true;
    this.data_choosed = item;
    this.blueChild.changeFilter('project' + this.data_choosed.$href);
    this.curator = this.data_choosed.kurator;
    this.ruk = this.data_choosed.rukovoditel;
    this.is_loading[0] = false;

  }
}
