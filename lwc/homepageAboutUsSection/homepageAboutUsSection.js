import { LightningElement, api } from "lwc";

export default class HomepageAboutUsSection extends LightningElement {
  @api tileHeight;
  @api showAppointments;
  @api showTasks;
  @api showButtons;

  // Appointments
  @api appointmentsTitleMain;
  @api labelBooked;
  @api labelCanceled;
  @api labelRescheduled;
  @api labelPurpose;
  @api labelAppointmentDateTime;
  @api labelViewDetails;

  // Tasks
  @api tasksTitleMain;
  @api labelMyTasks;
  @api labelLastUpdated;
  @api labelDueDate;
  @api labelTaskDescription;
  @api noTasksMsg;
  @api labelNotStarted;
  @api labelInProgress;
  @api labelCompleted;

  // Buttons
  @api btnLabels;
  @api btnTypes; // primary or secondary
  @api redirectToPage;
  @api horizontalAlign; // Left, Right, Center

  @api bookedDesc;
  @api canceledDesc;
  @api rescheduledDesc;

  @api keyLocation;
  @api keyDateTime;
  @api keyDuration;
  @api keyHost;
  @api keyParticipants;

  @api btnContactUs;
  @api btnGoBack;

  get appointmentKeys(){
    let obj = {
      'Location': this.keyLocation,
      'DateTime': this.keyDateTime,
      'Duration': this.keyDuration,
      'Host': this.keyHost,
      'Participants': this.keyParticipants
    }
    return obj;
  }

  get buttonLabels(){
    let obj = {
      'btnContactUs': this.btnContactUs,
      'btnGoBack': this.btnGoBack
    }
    return obj;
  }

}