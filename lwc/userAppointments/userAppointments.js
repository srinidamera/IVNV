import { LightningElement, api, wire } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import getUserAppointments from "@salesforce/apex/UserAppointmentsController.getUserAppointments";
import getPicklistValuesOfSubject from "@salesforce/apex/UserAppointmentsController.getPicklistValuesOfSubject";
import { formatStartEndDateTime, replaceStrings, formatDate } from "c/lwrUtils";
import { getContent } from "experience/cmsDeliveryApi";
import siteId from "@salesforce/site/Id";
import LANG from "@salesforce/i18n/lang";
import { getObjectInfo, getPicklistValuesByRecordType } from "lightning/uiObjectInfoApi";
import EVENT_OBJECT from "@salesforce/schema/Event";

export default class UserAppointments extends NavigationMixin(
  LightningElement
) {
  @api bookedDescKey;
  @api canceledDescKey;
  @api rescheduledDescKey;
  @api bookedDesc;
  @api canceledDesc;
  @api rescheduledDesc;
  @api appointmentKeys;
  @api buttonLabels;
 
  @api tileHeight;

  @api mainTitle = "Appointments";
  @api labelBooked;
  @api labelCanceled;
  @api labelRescheduled;
  @api labelPurpose;
  @api labelAppointmentDateTime;
  @api labelViewDetails;
  appointmentProps;
  showModal;
  selectedAppointment;

  statusToBadgeStyle = Object.freeze({
    BOOKED: "slds-badge_inverse badge-width font-weight-700 font-white",
    CANCELED:
      "slds-badge slds-theme_error badge-width font-weight-700 font-white",
    RESCHEDULED: "bg-yellow badge-width font-weight-700 font-black"
  });

  picklistValues;

  // @wire(getContent, {
  //   channelOrSiteId: siteId,
  //   contentKeyOrId: "$bookedDescKey"
  // })
  // getBookedDescription(result) {
  //   if (result?.data?.contentBody?.Value) {
  //     this.bookedDesc = result.data.contentBody.Value;
  //   }
  // }

  // @wire(getContent, {
  //   channelOrSiteId: siteId,
  //   contentKeyOrId: "$canceledDescKey"
  // })
  // getCanceledDescription(result) {
  //   if (result?.data?.contentBody?.Value) {
  //     this.canceledDesc = result.data.contentBody.Value;
  //   }
  // }

  // @wire(getContent, {
  //   channelOrSiteId: siteId,
  //   contentKeyOrId: "$rescheduledDescKey"
  // })
  // getRescheduledDescription(result) {
  //   if (result?.data?.contentBody?.Value) {
  //     this.rescheduledDesc = result.data.contentBody.Value;
  //   }
  // }

 
  @wire(getPicklistValuesOfSubject)
  wiredGetPicklistValuesOfSubject({data, error}){
    if (data) {
      this.picklistValues = data;
      if(this.appointmentProps){
        let tempAppointmentProps = this.buildAppointmentsProps(this.appointmentProps);
        this.appointmentProps = tempAppointmentProps;
      }
    }else {
      console.log("get picklist value error ==>:", error);
    }
  }

  @wire(getUserAppointments, {language: LANG})
  wiredGetAppointments({ data, error }) {
    if (data) {
      this.appointmentProps = this.buildAppointmentsProps(data);
      if(this.picklistValues){
        let tempAppointmentProps = this.buildAppointmentsProps(data);
        this.appointmentProps = tempAppointmentProps;
      }
    } else {
      console.log("Error in getUserAppointments:", error);
    }
  }

  buildAppointmentsProps(data) {
    console.log('appointmentKeys ===>',this.appointmentKeys);
    const statusToLabel = {
      BOOKED: this.labelBooked,
      CANCELED: this.labelCanceled,
      RESCHEDULED: this.labelRescheduled
    };

    const props = [];
    data.forEach((elem) => {
      console.log('elem ==>', elem);
      props.push({
        id: elem.evt?.Id,
        title: elem.evt?.Subject ? this.getLabelByValue(elem.evt?.Subject) : '',//elem.evt?.Subject,
        keyValPairs: [
          {
            key: this.labelPurpose,
            value: elem.evt?.Purpose__c
          },
          {
            key: this.labelAppointmentDateTime,
            value: formatStartEndDateTime(
              elem.evt?.StartDateTime,
              elem.evt?.EndDateTime
            )
          }
        ],
        showBadge: true,
        badgeLabel:
          statusToLabel[
            elem.evt?.sumoapp__AdditionalInfo__r?.sumoapp__Status__c
          ],
        badgeStyle:
          this.statusToBadgeStyle[
            elem.evt?.sumoapp__AdditionalInfo__r?.sumoapp__Status__c
          ],
        tileStyle: this.tileStyle,
        showHyperlink: true,
        hyperlinkTitle: this.labelViewDetails,
        modalContent: this.buildModalProps(elem)
      });
    });
    return props;
  }

  buildModalProps(elem) {
    const mergeFields = {
      "{Date_and_Time}": formatDate(elem.evt?.StartDateTime),
      "{counsellor_name}": elem.evt?.sumoapp__OrganizerFullName__c
    };
    const statusToDescription = {
      BOOKED: replaceStrings(this.bookedDesc, mergeFields),
      CANCELED: replaceStrings(this.canceledDesc, mergeFields),
      RESCHEDULED: replaceStrings(this.rescheduledDesc, mergeFields)
    };
    const props = {
      header: elem.evt?.Subject ? this.getLabelByValue(elem.evt?.Subject) : '',
      subHeader: elem.caseType,
      bodyProps: {
        description:
          statusToDescription[
            elem.evt?.sumoapp__AdditionalInfo__r?.sumoapp__Status__c
          ],
        keyValPairs: [
          {
            key: this.appointmentKeys.Location,
            value: elem.evt?.sumoapp__AdditionalInfo__r
              ?.sumoapp__GenerateVirtualDetails__c
              ? "Online"
              : elem.evt?.sumoapp__AdditionalInfo__r?.sumoapp__Location__r?.Name
          },
          {
            key: this.appointmentKeys.DateTime,
            value: formatStartEndDateTime(
              elem.evt?.StartDateTime,
              elem.evt?.EndDateTime
            )
          },
          {
            key: this.appointmentKeys.Duration,
            value: `${elem.evt?.sumoapp__AdditionalInfo__r?.sumoapp__Duration__c}mins`
          },
          {
            key: this.appointmentKeys.Host,
            value: elem.evt?.sumoapp__OrganizerFullName__c
          },
          {
            key: this.appointmentKeys.Participants,
            value: elem.participants?.length
              ? elem.participants?.join(", ")
              : ""
          }
        ]
      }
    };
    return props;
  }

  getLabelByValue(value) {
    if(this.picklistValues){
      const item = this.picklistValues.find(entry => entry.value === value);
      if(item){
        return item.label;
      } else {
        return value;
      }
      //return item ? item.label : 'Value not found';
    }
  }

  viewAppointmentDetails(event) {
    const recordId = event.detail.value;
    console.log("View Appoint Details", recordId);
    this.selectedAppointment = this.appointmentProps?.find(
      (elem) => elem.id === recordId
    )?.modalContent;
    console.log(
      "View Appoint Details",
      JSON.stringify(
        this.appointmentProps?.find((elem) => elem.id === recordId)
      )
    );
    this.showModal = true;
  }

  // Modal Functions
  gotoPage(event) {
    const pageName = event.target.value;
    if (pageName === "GO_BACK") {
      this.closeModal();
    } else {
      this[NavigationMixin.Navigate]({
        type: "comm__namedPage",
        attributes: {
          name: pageName
        }
      });
    }
  }

  closeModal() {
    this.selectedAppointment = null;
    this.showModal = false;
  }

  get tileStyle() {
    let style = "";
    if (this.tileHeight && parseInt(this.tileHeight) !== 0) {
      style = "height:" + this.tileHeight + "px;";
    } else {
      style = "height:88px;";
    }
    return style;
  }

  get showAppointments() {
    return this.appointmentProps?.length;
  }
}