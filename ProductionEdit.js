import React, { Component, Fragment } from 'react'
import { LineService } from '../../../shared/services/lines/LineService';
import Breadcrumb from '../../mics/Breadcrumb';
import { AuthenticationService } from "../../../shared/services/authentications/AuthenticationService";
import { ValidateForm } from "../../../shared/utilities/ValidateForm";
import { Toaster } from "../../../shared/utilities/Toaster";
import { ToasterTypeConstants } from "../../../shared/utilities/GlobalConstrants";
import { LineStationService } from '../../../shared/services/lineStation/LineStationService';
import { StationService } from '../../../shared/services/stations/StationService';
import Select from 'react-select'
import withAuth from '../../../shared/hoc/AuthComponent';
import { UserService } from '../../../shared/services/users/UserService';
import { withRouter } from '../../../shared/hoc/withRouter';
import { RequisitionService } from '../../../shared/services/requisitions/ResquisitionService';
import { ProductionService } from '../../../shared/services/productions/ProductionService';
import _ from 'lodash';
import { faBoxOpen, faPlay } from '@fortawesome/free-solid-svg-icons';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';

export class ProductionEdit extends Component {
    constructor(props) {
        super(props)

        this.state = {

            sortOrder: "",
            date: "",
            requisitionNo: "",
            productionStatus: "",
            requisitionId: 0,
            id: 0,
            viewItems: [],
            productionId: 0,
            model: '',
            dateInText: '',
            totalQuantity: 0,

            //validation
            error: {
                productionStatus: '',
            }
        }
    }

    componentDidMount = async () => {

        const { Id } = this.props.useParams;
        var viewItems = this.state.viewItems;

        let resToken = AuthenticationService.GetToken();
        if (!resToken.isSuccess) {
            Toaster.Notify({ type: ToasterTypeConstants.Warning, message: "Warning! Session Expired. Try to login first." });
            return;
        }

        //get station list for ddl

        let productionDetails = await this.getProductionDetails(Id, resToken.token);
        let requisitionDetails = await this.getRequisitionDetails(productionDetails.requisitionId, resToken.token);
        let productionTypeDetails = await this.getProductionLineStatus(Id, resToken.token);

        _.forEach(productionTypeDetails, (item) => {
            var viewItem =
            {
                type: item.type,
                done: item.done,
                totalQty: item.totalQty,
                lineStatus: item.lineStatus
            }
            viewItems.push(viewItem);
        })

        this.setState(
            {
                id: productionDetails.id,
                requisitionId: productionDetails.requisitionId,
                productionStatus: productionDetails.productionStatus,
                // date:  productionDetails.date,   
                requisitionNo: requisitionDetails.data.requisitionNo,
                dateInText: requisitionDetails.data.dateInText,
                model: requisitionDetails.data.model.name,
                viewItems: viewItems,
                productionId: Id,
                totalQuantity: requisitionDetails.data.itemQuantity,

            }
        )

    };

    getRequisitionDetails = async (Id, token) => {

        const res = await RequisitionService.GetDetailsById(Id, token);
        return res;

    };
    getProductionDetails = async (Id, token) => {

        const res = await ProductionService.GetDetailsById(Id, token);
        return res.data;

    };
    getProductionLineStatus = async (Id, token) => {

        let filter = { ProductionId: Id };
        const res = await ProductionService.GetProductionLineStatus(filter, token);
        return res.data;
    };

    handleInputChange = (event) => {
        const target = event.target;
        const value = target.value;
        const name = target.name;

        this.setState({
            [name]: value,
        });

        this.formValidationObject(name, value);
    };

    // validateFormOnLoginSubmit = () => {

    //     this.formValidationObject('lineId', this.state.lineId.toString());
    //     this.formValidationObject('lineLeaderUserId', this.state.lineLeaderUserId.toString());
    //     this.formValidationObject('date', this.state.date);
    //     this.formValidationObject('requisitionNo', this.state.requisitionNo);
    //     this.formValidationObject('manpower', this.state.manpower.toString());
    //     this.formValidationObject('manpowerPresent', this.state.manpowerPresent.toString());
    //     this.formValidationObject('manpowerAbsent', this.state.manpowerAbsent.toString());
    // }

    // formValidationObject = (name, value) => {
    //     let error = this.state.error;
    //     switch (name) {
    //         case "lineId":
    //             error.lineId = !value.length || value === '' ? "line is Required" : "";
    //             break;
    //         case "lineLeaderUserId":
    //             error.lineLeaderUserId = !value.length || value === '' ? "line Leader User is Required" : "";
    //             break;
    //         case "date":
    //             error.date = !value.length || value === '' ? "Date is Required" : "";
    //             break;
    //         case "requisitionNo":
    //             error.requisitionNo = !value.length || value === '' ? "RequisitionNo is Required" : "";
    //             break;
    //         case "Manpower":
    //             error.manpower = !value.length || value === '' ? "Manpower User is Required" : "";
    //             break;
    //         case "manpowerPresent":
    //             error.manpowerPresent = !value.length || value === '' ? "man power Present is Required" : "";
    //             break;
    //         case "manpowerAbsent":
    //             error.manpowerAbsent = !value.length || value === '' ? "Man power Absent is Required" : "";
    //             break;
    //         default:
    //             break;
    //     }

    //     this.setState({
    //         error,
    //         [name]: value
    //     })
    // };


    handleSubmit = async (e) => {
        // e.preventDefault();
        // this.validateFormOnLoginSubmit();
        // if (!ValidateForm(this.state.error)) {
        //     Toaster.Notify({ type: ToasterTypeConstants.Warning, message: "Warning! You must fill all the required fields" });
        //     return;
        // }

        const { id, lineId, requisitionId, lineLeaderUserId, date, manpower, manpowerPresent, manpowerAbsent } = this.state;
        let resToken = AuthenticationService.GetToken();
        if (!resToken.isSuccess) {
            Toaster.Notify({ type: ToasterTypeConstants.Warning, message: "Warning! Session Expired. Try to login first." });
            return;
        }

        const model = {
            Id: id,
            LineId: lineId,
            requisitionId: requisitionId,
            LineLeaderUserId: lineLeaderUserId,
            ProductionDate: date,
            Manpower: manpower,
            ManpowerPresent: manpowerPresent,
            ManpowerAbsent: manpowerAbsent,
            IsActive: true
        }

        const res = await ProductionService.Edit(model, resToken.token);

        if (res.response.isSuccess) {
            this.setState({
                lineId: "",
                lineLeaderUserId: "",
                lineLeaderUserId: 0,
                sortOrder: "",
                date: "",
                requisitionNo: "",
                manpower: "",
                manpowerPresent: "",
                manpowerAbsent: "",
                requisitionId: 0,
            })
            Toaster.Notify({ type: ToasterTypeConstants.Success, message: res.response.message });
            this.props.navigate(`/production`, { replace: true });
            return;
        }

        Toaster.Notify({ type: ToasterTypeConstants.Warning, message: res.response.message });


    };
    productionLineStatus = (item, status) => {
        let productionId = this.state.productionId;
        var status = status;
        this.props.navigate(`/production/add/${productionId}/${item.type}/${status}`, { replace: true });
    };
    productionLine = () => {
        let productionId = this.state.productionId;
        this.props.navigate(`/productionLine/update/${productionId}`, { replace: true });
    };
    endProduction = async (productionId) => {
        let resToken = AuthenticationService.GetToken();
        if (!resToken.isSuccess) {
            return;
        }
        this.props.navigate(`/storeInItem`, { replace: true });
        let filter = { ProductionId: productionId, Status: 'Logistic Approved'};
        var res = await RequisitionService.EndProduction(filter, resToken.token);
     
        Toaster.Notify({ type: ToasterTypeConstants.Success, message: res.response.message });
    };

    render() {
        const { productionStatus, requisitionNo, viewItems, model, dateInText, totalQuantity, productionId } = this.state;
        
        return (
            <Fragment>
                <div className="container-fluid">
                    <Breadcrumb
                        BreadcrumbParams={{
                            header: "Add Production",
                            title: "Production Add",
                            isDashboardMenu: false,
                            isThreeLayer: true,
                            threeLayerTitle: "Productions",
                            threeLayerLink: "/production",
                        }}
                    />

                    <div className="row">
                        <div className="col-xl-12 col-lg-12 col-sm-12">
                            <div className="row align-items-center">

                                {/* <form className="form-elements-wrapper" onSubmit={this.handleSubmit} noValidate> */}
                                <div className="card-style mb-30" style={{ marginBottom: "0px" }}>
                                    <div className="row">
                                        <div className="col-md-4">
                                            <div className="input-style-1">
                                                <label>
                                                    <b>Requisition No: </b> {requisitionNo}
                                                </label>

                                            </div>
                                        </div>
                                        <div className="col-md-4">
                                            <div className="input-style-1">
                                                <label>
                                                    <b>Model: </b> {model}
                                                </label>

                                            </div>
                                        </div>
                                        <div className="col-md-4">
                                            <div className="input-style-1">
                                                <label>
                                                    <b>Date: </b> {dateInText}
                                                </label>
                                            </div>
                                        </div>

                                    </div>
                                    <div className="row">
                                        <div className="col-md-4">
                                            <div className="input-style-1">
                                                <label>
                                                    <b>Production Status: </b> {productionStatus}
                                                </label>
                                            </div>
                                        </div>
                                        <div className="col-md-4">
                                            <div className="input-style-1">
                                                <label>
                                                    <b>Total Quantity: </b> {totalQuantity}
                                                </label>
                                            </div>
                                        </div>

                                    </div>

                                    {/* <div className="row">
                                            <div className="col-md-6">
                                                <div className="input-style-1">
                                                    <label>
                                                        <b>Date</b>
                                                    </label>
                                                    <input type="date" name="date" id="date" value={date} onChange={this.handleInputChange} />

                                                </div>
                                            </div>
                                        </div> */}
                                    <div className="row">
                                        <div className="col-xl-12 col-lg-12 col-sm-12">
                                            <div className="row align-items-center">
                                                <div className="card-style mb-30" style={{ marginBottom: "0px" }}>
                                                    <div className="table-wrapper table-responsive">
                                                        <table className="table table-striped table-hover">
                                                            <thead className="tbHead" style={{ background: 'rgb(126, 193, 223)', color: 'black', textAlign: 'Center', fontSize: 'small' }}>
                                                                <tr>
                                                                    <th>
                                                                        Line
                                                                    </th>
                                                                    <th>
                                                                        Production
                                                                    </th>
                                                                    <th>
                                                                        total
                                                                    </th>
                                                                    <th> Status </th>
                                                                </tr>
                                                            </thead>
                                                            <tbody style={{ textAlign: 'Center' }}>
                                                                {viewItems.map((item, i) => {
                                                                    return (
                                                                        <tr key={`item-${i}`}>
                                                                            <td className="p-2" >
                                                                                {/* <input className="form-control" readOnly type="text" defaultValue={item.type} /> */}
                                                                                {item.type}
                                                                            </td>
                                                                            <td className="p-2">
                                                                                {/* <input className="form-control" type="text" name="quantity" id="quantity" onChange={(event) => this.handleInputQuantity(event, item)} autoComplete="off" value={item.quantity}/> */}
                                                                                {item.done}
                                                                            </td>
                                                                            <td className="p-2">
                                                                                {item.totalQty}
                                                                            </td>

                                                                            <td className="p-2"><b>{item.lineStatus}</b>
                                                                                <div>
                                                                                    {/* {item.lineStatus == "Pending" && item.type == "Assemble" &&
                                                                                        <button className="btn btn-sm warning-btn rounded-full m-1" onClick={() => this.productionLineStatus(item, 'OnGoing')} title='Update Production Line'>
                                                                                            Start Production
                                                                                        </button>
                                                                                    } */}
                                                                                    {item.lineStatus == "OnGoing" && item.type == "Assemble" &&
                                                                                        <button className="btn btn-sm warning-btn rounded-full m-1" onClick={() => this.productionLineStatus(item, 'Complete')} title='Update Production Line'>
                                                                                            Complete
                                                                                        </button>
                                                                                    }
                                                                                    {/* {item.lineStatus == "OnGoing" && item.type == "Assemble" &&
                                                                                        <button className="btn btn-sm warning-btn rounded-full m-1" onClick={() => this.productionLineStatus(item, 'Complete')} title='Update Production Line'>
                                                                                            Complete
                                                                                        </button>
                                                                                    } */}
                                                                                    {/* {item.type == "Packaging" && productionStatus == "Assemble End" &&
                                                                                        <button className="btn btn-sm warning-btn rounded-full m-1" onClick={() => this.productionLineStatus(item, 'OnGoing')} title='Update Production Line'>
                                                                                            Pack Production
                                                                                        </button>
                                                                                    } */}
                                                                                    {/* {item.type == "Packaging" && productionStatus == "Packaging On Process" &&
                                                                                        <button className="btn btn-sm warning-btn rounded-full m-1" onClick={() => this.productionLineStatus(item, 'OnGoing')} title='Update Production Line'>
                                                                                            Pack Production
                                                                                        </button>
                                                                                    } */}
                                                                                    {item.type == "Packaging" && productionStatus == "Packaging On Process" &&
                                                                                        <button className="btn btn-sm warning-btn rounded-full m-1" onClick={() => this.productionLineStatus(item, 'Complete')} title='Update Production Line'>
                                                                                            Complete
                                                                                        </button>
                                                                                    }
                                                                                    {/* {item.lineStatus == "OnGoing" && item.type == "Packaging" &&
                                                                                        <button className="btn btn-sm warning-btn rounded-full m-1" onClick={() => this.productionLineStatus(item, 'Complete')} title='Update Production Line'>
                                                                                            Complete
                                                                                        </button>
                                                                                    } */}
                                                                                </div>
                                                                            </td>
                                                                        </tr>
                                                                    );
                                                                })
                                                                }
                                                            </tbody>
                                                        </table>


                                                    </div>
                                                    <div className="row">
                                                        <div className="col-md-6">
                                                            <div className=" button-group d-flex justify-content-left flex-wrap">
                                                                <button className="main-btn primary-btn btn-hover w-60 text-center" onClick={() => this.productionLine()}> Line Setup </button>
                                                            </div>
                                                        </div>
                                                        <div className="col-md-3"></div>
                                                        {productionStatus == 'Packaging End' &&
                                                            <div className="col-md-3" style={{paddingLeft:'60px'}}>
                                                                <div className=" button-group d-flex justify-content-right flex-wrap">
                                                                    <button
                                                                        className="main-btn info-btn btn-hover w-60 text-center"
                                                                        onClick={() => this.endProduction(productionId)}
                                                                    >
                                                                        Logistic Approve &nbsp;
                                                                        <FontAwesomeIcon icon={faBoxOpen} />
                                                                    </button>
                                                                </div>
                                                            </div>
                                                        }
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                {/* </form> */}

                            </div>

                        </div>
                    </div>
                </div>

            </Fragment>
        )
    }
}

export default withAuth(withRouter(ProductionEdit));
