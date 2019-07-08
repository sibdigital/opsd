import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { WpSendEmailButtonComponent } from './wp-send-email-button.component';

describe('WpSendEmailButtonComponent', () => {
  let component: WpSendEmailButtonComponent;
  let fixture: ComponentFixture<WpSendEmailButtonComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ WpSendEmailButtonComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(WpSendEmailButtonComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
